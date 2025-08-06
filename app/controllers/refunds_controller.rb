class RefundsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_user!
  before_action :set_payment
  before_action :check_refund_eligibility

  def new
    @refund_amount = calculate_refund_amount
    @refund_reasons = [
      "경기가 취소되었습니다",
      "개인 사정으로 참가할 수 없습니다",
      "날씨/코트 상태 불량",
      "잘못된 경기 정보",
      "기타"
    ]
  end

  def create
    ActiveRecord::Base.transaction do
      # 환불 처리
      @payment.update!(
        status: "refunded",
        refund_reason: refund_params[:refund_reason],
        refund_amount: calculate_refund_amount,
        refunded_at: Time.current
      )

      # 경기 신청 취소
      @payment.game_application.update!(
        status: "cancelled",
        cancelled_at: Time.current,
        cancellation_reason: refund_params[:refund_reason]
      )

      # 유저 취소 기록 업데이트
      update_user_cancellation_record

      # 토스페이먼츠 환불 API 호출
      if process_toss_refund
        # 알림 생성
        create_refund_notification

        flash[:success] = "환불이 성공적으로 처리되었습니다. 환불 금액: #{number_to_currency(@payment.refund_amount)}"
        redirect_to game_path(@payment.game)
      else
        raise ActiveRecord::Rollback
        flash[:error] = "환불 처리 중 오류가 발생했습니다. 고객센터에 문의해주세요."
        redirect_to new_game_payment_refund_path(@payment.game, @payment)
      end
    end
  rescue => e
    Rails.logger.error "Refund error: #{e.message}"
    flash[:error] = "환불 처리 중 오류가 발생했습니다: #{e.message}"
    redirect_to game_path(@payment.game)
  end

  private

  def set_payment
    @payment = current_user.payments.find(params[:payment_id])
    @game = @payment.game
  end

  def check_refund_eligibility
    unless can_refund?(@payment)
      flash[:error] = refund_error_message
      redirect_to game_path(@payment.game)
    end
  end

  def can_refund?(payment)
    return false if payment.status == "refunded"
    return false if payment.game.start_time < 24.hours.from_now
    return false unless [ "completed", "paid" ].include?(payment.status)
    true
  end

  def refund_error_message
    if @payment.status == "refunded"
      "이미 환불 처리된 결제입니다."
    elsif @payment.game.start_time < 24.hours.from_now
      "경기 시작 24시간 이내에는 환불이 불가능합니다."
    else
      "환불이 불가능한 상태입니다."
    end
  end

  def calculate_refund_amount
    # 환불 정책에 따른 금액 계산
    days_until_game = (@payment.game.start_time - Time.current) / 1.day

    if days_until_game >= 7
      # 7일 이상: 전액 환불
      @payment.amount
    elsif days_until_game >= 3
      # 3-7일: 80% 환불
      (@payment.amount * 0.8).round
    elsif days_until_game >= 1
      # 1-3일: 50% 환불
      (@payment.amount * 0.5).round
    else
      # 24시간 이내: 환불 불가
      0
    end
  end

  def process_toss_refund
    # TossPayments 환불 API 호출
    toss_client = TossPaymentsClient.new

    response = toss_client.cancel_payment(
      payment_key: @payment.payment_key,
      cancel_reason: @payment.refund_reason,
      cancel_amount: @payment.refund_amount
    )

    if response[:success]
      @payment.update!(
        toss_refund_id: response[:cancellation_id],
        refund_status: "completed"
      )
      true
    else
      Rails.logger.error "TossPayments refund failed: #{response[:error]}"
      false
    end
  rescue => e
    Rails.logger.error "TossPayments API error: #{e.message}"
    false
  end

  def update_user_cancellation_record
    # 유저의 취소 기록 업데이트
    cancellation = current_user.user_cancellation || current_user.build_user_cancellation

    cancellation.increment(:total_cancellations)
    cancellation.increment(:weekly_cancellations) if cancellation.week_start == Date.current.beginning_of_week

    # 주간 취소 횟수 초기화 (새로운 주)
    if cancellation.week_start != Date.current.beginning_of_week
      cancellation.weekly_cancellations = 1
      cancellation.week_start = Date.current.beginning_of_week
    end

    cancellation.last_cancellation_at = Time.current
    cancellation.save!

    # 취소 제한 확인
    if cancellation.weekly_cancellations >= 3
      current_user.update!(
        can_apply_until: 7.days.from_now,
        restriction_reason: "주간 취소 횟수 초과 (#{cancellation.weekly_cancellations}회)"
      )
    end
  end

  def create_refund_notification
    Notification.create!(
      user: current_user,
      notification_type: "refund_completed",
      title: "환불 완료",
      message: "#{@game.title} 경기의 참가비 #{number_to_currency(@payment.refund_amount)}가 환불되었습니다.",
      related_type: "Payment",
      related_id: @payment.id
    )

    # 호스트에게도 알림
    Notification.create!(
      user: @game.organizer,
      notification_type: "participant_cancelled",
      title: "참가자 취소",
      message: "#{current_user.display_name}님이 #{@game.title} 경기 참가를 취소했습니다.",
      related_type: "Game",
      related_id: @game.id
    )
  end

  def refund_params
    params.require(:refund).permit(:refund_reason)
  end

  def number_to_currency(amount)
    "#{number_with_delimiter(amount)}원"
  end

  def number_with_delimiter(number)
    number.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\\1,')
  end
end
