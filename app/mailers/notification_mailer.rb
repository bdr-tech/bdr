class NotificationMailer < ApplicationMailer
  default from: "noreply@bdr-platform.com"

  # 새로운 경기 신청 알림 (호스트에게)
  def new_game_application(game_application)
    @game_application = game_application
    @game = game_application.game
    @applicant = game_application.user
    @host = @game.organizer

    mail(
      to: @host.email,
      subject: "[BDR] #{@applicant.nickname || @applicant.name}님이 경기 참가를 신청했습니다"
    )
  end

  # 참가 승인 알림 (신청자에게)
  def application_approval(game_application)
    @game_application = game_application
    @game = game_application.game
    @user = game_application.user
    @needs_payment = @game.fee.present? && @game.fee > 0

    subject = if @needs_payment
      "[BDR] 경기 참가가 승인되었습니다 - 참가비 입금 안내"
    else
      "[BDR] 경기 참가가 승인되었습니다"
    end

    mail(
      to: @user.email,
      subject: subject
    )
  end

  # 입금 확인 알림 (신청자에게)
  def payment_confirmation(payment)
    @payment = payment
    @game_application = payment.game_application
    @game = @game_application.game
    @user = @game_application.user

    mail(
      to: @user.email,
      subject: "[BDR] 참가비 입금이 확인되었습니다"
    )
  end

  # 참가 거절 알림 (신청자에게)
  def application_rejection(game_application)
    @game_application = game_application
    @game = game_application.game
    @user = game_application.user

    mail(
      to: @user.email,
      subject: "[BDR] 경기 참가 신청이 거절되었습니다"
    )
  end

  # 송금 완료 알림 (호스트에게)
  def payment_transferred(payment)
    @payment = payment
    @game = payment.game
    @host = @game.organizer
    @total_amount = payment.amount
    @platform_fee = payment.platform_fee
    @host_amount = payment.host_amount

    mail(
      to: @host.email,
      subject: "[BDR] 경기 참가비가 송금되었습니다"
    )
  end

  # 경기 취소 알림 (참가자에게)
  def game_cancelled(game_participation)
    @game = game_participation.game
    @user = game_participation.user

    mail(
      to: @user.email,
      subject: "[BDR] 참가 예정 경기가 취소되었습니다"
    )
  end

  # 경기 리마인더 (참가자에게)
  def game_reminder(game_participation)
    @game = game_participation.game
    @user = game_participation.user

    mail(
      to: @user.email,
      subject: "[BDR] 내일 경기가 있습니다!"
    )
  end
end
