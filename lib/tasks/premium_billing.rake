namespace :premium do
  desc "Process monthly premium subscription renewals"
  task process_renewals: :environment do
    puts "[#{Time.current}] Starting premium subscription renewal process..."

    # 만료 예정인 구독 찾기 (3일 이내)
    expiring_subscriptions = User.joins(:premium_subscriptions)
                                 .where(is_premium: true)
                                 .where("premium_expires_at <= ?", 3.days.from_now)
                                 .where("premium_expires_at > ?", Time.current)

    processed_count = 0
    success_count = 0
    failed_count = 0

    expiring_subscriptions.find_each do |user|
      begin
        # 활성 구독 찾기
        active_subscription = user.premium_subscriptions.active.last
        next unless active_subscription

        # 활성 빌링키 찾기
        billing_key = user.billing_keys.active.last
        unless billing_key
          puts "  [ERROR] User #{user.id} has no active billing key"
          failed_count += 1
          next
        end

        # 자동결제 실행
        toss_client = TossPaymentsClient.new
        amount = case active_subscription.plan_type
        when "monthly" then 3900
        when "yearly" then 149000
        else next
        end

        order_id = "PREMIUM_RENEWAL_#{user.id}_#{Time.current.to_i}"

        result = toss_client.billing_payment(
          billing_key: billing_key.billing_key,
          customer_key: billing_key.customer_key,
          amount: amount,
          order_id: order_id,
          order_name: "BDR 프리미엄 #{active_subscription.plan_type == 'monthly' ? '월간' : '연간'} 구독 갱신"
        )

        if result[:success]
          # 새 구독 생성
          new_subscription = PremiumSubscription.create!(
            user: user,
            plan_type: active_subscription.plan_type,
            payment_key: result[:payment_key],
            order_id: result[:order_id],
            amount: amount,
            status: "active",
            started_at: user.premium_expires_at || Time.current
          )

          # 사용자 프리미엄 만료일 연장
          extension_period = active_subscription.plan_type == "monthly" ? 1.month : 1.year
          user.update!(
            premium_expires_at: user.premium_expires_at + extension_period
          )

          billing_key.use!

          # 알림 발송
          Notification.create!(
            user: user,
            notification_type: "premium_renewed",
            title: "프리미엄 구독 갱신 완료",
            message: "프리미엄 구독이 자동으로 갱신되었습니다. 다음 결제일: #{user.premium_expires_at.strftime('%Y년 %m월 %d일')}",
            data: { subscription_id: new_subscription.id }
          )

          puts "  [SUCCESS] User #{user.id} subscription renewed"
          success_count += 1
        else
          puts "  [FAILED] User #{user.id} payment failed: #{result[:error]}"

          # 결제 실패 알림
          Notification.create!(
            user: user,
            notification_type: "premium_payment_failed",
            title: "프리미엄 구독 결제 실패",
            message: "자동결제가 실패했습니다. 결제 수단을 확인해주세요.",
            priority: 2
          )

          failed_count += 1
        end

        processed_count += 1
      rescue => e
        puts "  [ERROR] User #{user.id}: #{e.message}"
        failed_count += 1
      end
    end

    puts "[#{Time.current}] Renewal process completed:"
    puts "  Total processed: #{processed_count}"
    puts "  Success: #{success_count}"
    puts "  Failed: #{failed_count}"
  end

  desc "Cancel expired premium subscriptions"
  task cancel_expired: :environment do
    puts "[#{Time.current}] Checking for expired premium subscriptions..."

    # 만료된 프리미엄 사용자 찾기
    expired_users = User.where(is_premium: true)
                        .where("premium_expires_at < ?", Time.current)

    expired_count = 0

    expired_users.find_each do |user|
      user.update!(
        is_premium: false,
        premium_type: nil
      )

      # 구독 상태 업데이트
      user.premium_subscriptions.active.update_all(
        status: "expired",
        cancelled_at: Time.current
      )

      # 알림 발송
      Notification.create!(
        user: user,
        notification_type: "premium_expired",
        title: "프리미엄 구독 만료",
        message: "프리미엄 구독이 만료되었습니다. 계속 이용하시려면 재구독해주세요.",
        priority: 2
      )

      expired_count += 1
      puts "  User #{user.id} premium subscription expired"
    end

    puts "[#{Time.current}] Expired #{expired_count} subscriptions"
  end
end
