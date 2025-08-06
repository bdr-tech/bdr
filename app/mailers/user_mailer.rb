class UserMailer < ApplicationMailer
  default from: "noreply@bdr-platform.com"

  # 경기 신청 승인 알림
  def application_approved(game_application)
    @application = game_application
    @user = @application.user
    @game = @application.game

    mail(
      to: @user.email,
      subject: "[BDR] 경기 신청이 승인되었습니다 - #{@game.title}"
    )
  end

  # 경기 신청 거절 알림
  def application_rejected(game_application)
    @application = game_application
    @user = @application.user
    @game = @application.game

    mail(
      to: @user.email,
      subject: "[BDR] 경기 신청이 거절되었습니다 - #{@game.title}"
    )
  end

  # 결제 대기 알림
  def payment_required(game_application)
    @application = game_application
    @user = @application.user
    @game = @application.game
    @payment_deadline = @application.payment_deadline

    mail(
      to: @user.email,
      subject: "[BDR] 결제를 완료해주세요 - #{@game.title}"
    )
  end

  # 결제 완료 알림
  def payment_confirmed(payment)
    @payment = payment
    @user = @payment.user
    @game = @payment.game
    @application = @payment.game_application

    mail(
      to: @user.email,
      subject: "[BDR] 결제가 완료되었습니다 - #{@game.title}"
    )
  end

  # 경기 24시간 전 리마인더
  def game_reminder(game_application)
    @application = game_application
    @user = @application.user
    @game = @application.game

    mail(
      to: @user.email,
      subject: "[BDR] 내일 경기가 있습니다! - #{@game.title}"
    )
  end

  # 경기 취소 알림 (호스트가 취소)
  def game_cancelled(game_application)
    @application = game_application
    @user = @application.user
    @game = @application.game

    mail(
      to: @user.email,
      subject: "[BDR] 경기가 취소되었습니다 - #{@game.title}"
    )
  end

  # 환불 완료 알림
  def refund_completed(payment)
    @payment = payment
    @user = @payment.user
    @game = @payment.game
    @refund_amount = @payment.refund_amount

    mail(
      to: @user.email,
      subject: "[BDR] 환불이 완료되었습니다 - #{@game.title}"
    )
  end

  # 호스트: 새로운 신청자 알림
  def new_application_for_host(game_application)
    @application = game_application
    @applicant = @application.user
    @game = @application.game
    @host = @game.organizer

    mail(
      to: @host.email,
      subject: "[BDR] 새로운 경기 신청이 있습니다 - #{@applicant.display_name}"
    )
  end

  # 호스트: 참가자 취소 알림
  def participant_cancelled_for_host(game_application)
    @application = game_application
    @participant = @application.user
    @game = @application.game
    @host = @game.organizer

    mail(
      to: @host.email,
      subject: "[BDR] 참가자가 취소했습니다 - #{@participant.display_name}"
    )
  end

  # 호스트: 경기 2일 후 정산 가능 알림
  def settlement_available(game)
    @game = game
    @host = @game.organizer
    @total_revenue = @game.revenue_generated
    @platform_fee = @game.platform_fee_amount
    @settlement_amount = @game.host_payment_amount

    mail(
      to: @host.email,
      subject: "[BDR] 정산이 가능합니다 - #{@game.title}"
    )
  end

  # 신규 회원 환영 이메일
  def welcome_email(user)
    @user = user

    mail(
      to: @user.email,
      subject: "[BDR] BDR 플랫폼에 오신 것을 환영합니다!"
    )
  end

  # 프리미엄 구독 시작
  def premium_subscription_started(user)
    @user = user
    @premium_type = @user.premium_type
    @expires_at = @user.premium_expires_at

    mail(
      to: @user.email,
      subject: "[BDR] 프리미엄 멤버십이 시작되었습니다"
    )
  end

  # 프리미엄 만료 예정 알림 (7일 전)
  def premium_expiring_soon(user)
    @user = user
    @expires_at = @user.premium_expires_at
    @days_remaining = @user.premium_days_remaining

    mail(
      to: @user.email,
      subject: "[BDR] 프리미엄 멤버십이 곧 만료됩니다"
    )
  end
end
