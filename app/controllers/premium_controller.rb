require_relative "../services/toss_payments_client"

class PremiumController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :require_login
  skip_before_action :verify_authenticity_token, only: [ :payment_success, :billing_success ]

  def index
    @user = current_user
  end

  def subscribe
    if request.get?
      # Display payment form for the selected plan
      @plan_type = params[:type] || "monthly"
      @plan_price = get_plan_price(@plan_type)
      @order_id = "PREMIUM_#{current_user.id}_#{Time.current.to_i}"
      render :subscribe
    else
      process_subscription
    end
  end

  private

  def process_subscription
    plan_type = params[:plan_type]

    case plan_type
    when "monthly"
      current_user.update!(
        is_premium: true,
        premium_type: "monthly",
        premium_expires_at: 1.month.from_now
      )
      redirect_to stats_path, notice: "프리미엄 월간 이용권을 구독하였습니다!"
    when "yearly"
      current_user.update!(
        is_premium: true,
        premium_type: "yearly",
        premium_expires_at: 1.year.from_now
      )
      redirect_to stats_path, notice: "프리미엄 연간 이용권을 구독하였습니다!"
    when "lifetime"
      current_user.update!(
        is_premium: true,
        premium_type: "lifetime",
        premium_expires_at: nil
      )
      redirect_to stats_path, notice: "프리미엄 평생 이용권을 구독하였습니다!"
    else
      redirect_to premium_path, alert: "잘못된 요청입니다."
    end
  end

  def get_plan_price(plan_type)
    case plan_type
    when "monthly"
      3900
    when "yearly"
      149000
    when "lifetime"
      290000
    else
      3900
    end
  end

  public

  def payment_success
    payment_key = params[:paymentKey]
    order_id = params[:orderId]
    amount = params[:amount]
    plan_type = params[:plan_type]

    # Verify payment with TossPayments
    toss_client = TossPaymentsClient.new

    begin
      # Confirm payment
      payment_result = toss_client.confirm_payment(
        payment_key: payment_key,
        order_id: order_id,
        amount: amount.to_i
      )

      if payment_result["status"] == "DONE"
        # Create premium subscription record
        subscription = PremiumSubscription.create!(
          user: current_user,
          plan_type: plan_type,
          payment_key: payment_key,
          order_id: order_id,
          amount: amount.to_i,
          status: "active",
          started_at: Time.current
        )

        # Update user premium status
        case plan_type
        when "monthly"
          current_user.update!(
            is_premium: true,
            premium_type: "monthly",
            premium_expires_at: 1.month.from_now
          )
        when "yearly"
          current_user.update!(
            is_premium: true,
            premium_type: "yearly",
            premium_expires_at: 1.year.from_now
          )
        when "lifetime"
          current_user.update!(
            is_premium: true,
            premium_type: "lifetime",
            premium_expires_at: nil
          )
        end

        redirect_to premium_path, notice: "프리미엄 구독이 완료되었습니다!"
      else
        redirect_to premium_path, alert: "결제 확인에 실패했습니다. 고객센터에 문의해주세요."
      end
    rescue => e
      Rails.logger.error "Premium payment error: #{e.message}"
      redirect_to premium_path, alert: "결제 처리 중 오류가 발생했습니다: #{e.message}"
    end
  end

  def payment_fail
    error_code = params[:code]
    error_message = params[:message]

    Rails.logger.error "Premium payment failed: #{error_code} - #{error_message}"

    redirect_to premium_path, alert: "결제가 취소되었거나 실패했습니다. 다시 시도해주세요."
  end

  def billing_success
    Rails.logger.info "=== Billing Success Called ==="
    Rails.logger.info "Params: #{params.inspect}"
    Rails.logger.info "Session: #{session.inspect}"

    auth_key = params[:authKey]
    customer_key = params[:customerKey] || params[:customer_key]
    plan_type = params[:plan_type] || session[:premium_plan_type] || "monthly"

    Rails.logger.info "AuthKey: #{auth_key}, CustomerKey: #{customer_key}, PlanType: #{plan_type}"

    # customer_key가 없으면 현재 사용자 ID로 생성
    if customer_key.blank?
      customer_key = BillingKey.generate_customer_key(current_user.id)
      Rails.logger.info "Generated CustomerKey: #{customer_key}"
    end

    # 빌링키 발급
    toss_client = TossPaymentsClient.new
    result = toss_client.issue_billing_key(
      customer_key: customer_key,
      auth_key: auth_key
    )

    if result[:success]
      # 빌링키 저장
      billing_key = current_user.billing_keys.create!(
        customer_key: customer_key,
        billing_key: result[:billing_key],
        card_number: result[:card_number],
        card_company: result[:card_company],
        card_type: "신용/체크" # TODO: API에서 받아오기
      )

      # 첨 결제 실행
      amount = get_plan_price(plan_type)
      order_id = "PREMIUM_AUTO_#{current_user.id}_#{Time.current.to_i}"

      payment_result = toss_client.billing_payment(
        billing_key: billing_key.billing_key,
        customer_key: customer_key,
        amount: amount,
        order_id: order_id,
        order_name: "BDR 프리미엄 #{plan_type == 'monthly' ? '월간' : '연간'} 구독"
      )

      if payment_result[:success]
        # 구독 생성
        subscription = PremiumSubscription.create!(
          user: current_user,
          plan_type: plan_type,
          payment_key: payment_result[:payment_key],
          order_id: payment_result[:order_id],
          amount: amount,
          status: "active",
          started_at: Time.current
        )

        # 사용자 프리미엄 상태 업데이트
        case plan_type
        when "monthly"
          current_user.update!(
            is_premium: true,
            premium_type: "monthly",
            premium_expires_at: 1.month.from_now
          )
        when "yearly"
          current_user.update!(
            is_premium: true,
            premium_type: "yearly",
            premium_expires_at: 1.year.from_now
          )
        end

        billing_key.use!

        redirect_to premium_path, notice: "프리미엄 자동결제가 설정되었습니다! 매달 자동으로 결제됩니다."
      else
        Rails.logger.error "Payment failed: #{payment_result[:error]}"
        redirect_to premium_path, alert: "첫 결제에 실패했습니다: #{payment_result[:error]}"
      end
    else
      Rails.logger.error "Billing key issue failed: #{result[:error]}"
      redirect_to premium_path, alert: "카드 등록에 실패했습니다: #{result[:error]}"
    end
  rescue => e
    Rails.logger.error "Billing success error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to premium_path, alert: "결제 처리 중 오류가 발생했습니다: #{e.message}"
  end

  def manage
    @active_subscriptions = current_user.premium_subscriptions.active
    @past_subscriptions = current_user.premium_subscriptions.where.not(status: "active").recent.limit(10)
  end

  def cancel
    subscription = current_user.premium_subscriptions.active.find(params[:subscription_id])

    if subscription.cancel!
      # Process refund if applicable
      days_used = (Date.current - subscription.started_at.to_date).to_i

      refund_policy = case subscription.plan_type
      when "monthly"
        days_used <= 7 ? 0.5 : 0  # 7일 이내 50% 환불
      when "yearly"
        days_used <= 30 ? 0.7 : 0  # 30일 이내 70% 환불
      else
        0
      end

      if refund_policy > 0
        refund_amount = (subscription.amount * refund_policy).to_i
        subscription.refund!(refund_amount)
        flash[:notice] = "프리미엄 구독이 취소되었고, #{number_to_currency(refund_amount)}가 환불됩니다."
      else
        flash[:notice] = "프리미엄 구독이 취소되었습니다."
      end
    else
      flash[:alert] = "구독 취소에 실패했습니다."
    end

    redirect_to premium_manage_path
  end
end
