namespace :games do
  desc "Send reminder emails for games starting in 24 hours"
  task send_reminders: :environment do
    # 24시간 후에 시작하는 경기들 찾기
    games_tomorrow = Game.where(
      start_time: 23.hours.from_now..25.hours.from_now,
      status: [ "upcoming", "recruiting" ]
    )

    reminder_count = 0

    games_tomorrow.each do |game|
      # 최종 승인된 참가자들에게 리마인더 발송
      applications = game.game_applications.where(status: "final_approved")

      applications.each do |application|
        # 이미 리마인더를 보냈는지 확인
        unless application.reminder_sent_at.present? && application.reminder_sent_at > 12.hours.ago
          UserMailer.game_reminder(application).deliver_later
          application.update!(
            reminder_sent_at: Time.current,
            reminder_count: application.reminder_count.to_i + 1
          )
          reminder_count += 1
        end
      end

      # 호스트에게도 리마인더 발송
      host_application = game.game_applications.find_or_create_by(user: game.organizer) do |app|
        app.status = "final_approved"
        app.applied_at = Time.current
      end

      unless host_application.reminder_sent_at.present? && host_application.reminder_sent_at > 12.hours.ago
        UserMailer.game_reminder(host_application).deliver_later
        host_application.update!(
          reminder_sent_at: Time.current,
          reminder_count: host_application.reminder_count.to_i + 1
        )
        reminder_count += 1
      end
    end

    puts "Sent #{reminder_count} reminder emails for #{games_tomorrow.count} games"
  end

  desc "Send settlement available notifications"
  task send_settlement_notifications: :environment do
    # 2일 전에 완료된 경기들 찾기
    games_for_settlement = Game.where(
      status: "completed",
      end_time: 50.hours.ago..46.hours.ago
    ).where("revenue_generated > 0")

    settlement_count = 0

    games_for_settlement.each do |game|
      # 정산 알림을 아직 보내지 않은 경기들
      unless game.settlement_notified_at.present?
        UserMailer.settlement_available(game).deliver_later
        game.update!(settlement_notified_at: Time.current)
        settlement_count += 1
      end
    end

    puts "Sent #{settlement_count} settlement notifications"
  end

  desc "Check and send premium expiration reminders"
  task check_premium_expiration: :environment do
    # 7일 후에 만료되는 프리미엄 회원들
    expiring_users = User.where(
      is_premium: true,
      premium_expires_at: 6.days.from_now..8.days.from_now
    ).where.not(premium_type: "lifetime")

    reminder_count = 0

    expiring_users.each do |user|
      # 최근 7일 이내에 알림을 보냈는지 확인
      last_reminder = user.notifications.where(
        notification_type: "premium_expiring_soon",
        created_at: 7.days.ago..Time.current
      ).exists?

      unless last_reminder
        UserMailer.premium_expiring_soon(user).deliver_later

        # 알림 기록 생성
        Notification.create!(
          user: user,
          notification_type: "premium_expiring_soon",
          title: "프리미엄 멤버십 만료 예정",
          message: "프리미엄 멤버십이 #{user.premium_days_remaining}일 후 만료됩니다.",
          is_read: false
        )

        reminder_count += 1
      end
    end

    puts "Sent #{reminder_count} premium expiration reminders"
  end
end
