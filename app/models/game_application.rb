class GameApplication < ApplicationRecord
  belongs_to :user
  belongs_to :game
  has_one :payment, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[pending waiting_payment final_approved rejected] }
  validates :applied_at, presence: true
  validates :user_id, uniqueness: { scope: :game_id, message: "이미 이 경기에 신청했습니다" }

  scope :pending, -> { where(status: "pending") }
  scope :waiting_payment, -> { where(status: "waiting_payment") }
  scope :final_approved, -> { where(status: "final_approved") }
  scope :rejected, -> { where(status: "rejected") }

  # 기존 approved 스코프는 waiting_payment와 final_approved 모두 포함
  scope :approved, -> { where(status: [ "waiting_payment", "final_approved" ]) }

  before_validation :set_applied_at, on: :create

  # 알림 콜백
  after_create :notify_host_of_application
  after_update :notify_status_change

  def approve!
    transaction do
      current_time = Time.current

      # 경기 참가비가 있으면 입금대기중 상태로 변경
      if game.fee.present? && game.fee > 0
        update!(status: "waiting_payment", approved_at: current_time)

        # 결제 생성
        create_payment!(
          amount: game.fee,
          status: "pending",
          payment_method: "bank_transfer",
          bdr_account_info: Payment.bdr_account_info.to_json
        )
      else
        # 무료 경기는 바로 최종 승인
        update!(
          status: "final_approved",
          approved_at: current_time,
          final_approved_at: current_time
        )
      end
    end
  end

  def reject!
    update!(status: "rejected", rejected_at: Time.current)
  end

  def pending?
    status == "pending"
  end

  def waiting_payment?
    status == "waiting_payment"
  end

  def final_approved?
    status == "final_approved"
  end

  def approved?
    status.in?([ "waiting_payment", "final_approved" ])
  end

  def rejected?
    status == "rejected"
  end

  # 결제 관련 메서드
  def needs_payment?
    waiting_payment? && game.fee.present? && game.fee > 0 && (payment.nil? || payment.pending?)
  end

  def payment_completed?
    payment.present? && payment.paid?
  end

  def payment_status_text
    return "무료" if game.fee.blank? || game.fee == 0
    return "입금 대기" if waiting_payment?
    return "결제 완료" if final_approved?
    return "송금 완료" if payment.present? && payment.transferred?
    "미결제"
  end

  # 결제 확인 처리 (입금대기중 → 최종승인)
  def confirm_payment!
    return false unless waiting_payment?
    return false unless payment.present?

    transaction do
      payment.confirm_payment!
      update!(
        status: "final_approved",
        payment_confirmed_at: Time.current,
        final_approved_at: Time.current
      )
    end
    true
  end

  def cancel!
    # 취소 횟수 증가
    UserCancellation.increment_cancellation(user)

    # 신청 삭제
    destroy!
  end

  private

  def set_applied_at
    self.applied_at ||= Time.current
  end

  def notify_host_of_application
    Notification.create_for_user(
      game.organizer,
      "game_application_received",
      {
        title: "새로운 경기 참가 신청",
        message: "#{user.nickname || user.name}님이 '#{game.title}' 경기에 참가 신청했습니다.",
        notifiable: game,
        priority: "high"
      }
    )
  rescue => e
    Rails.logger.error "Failed to create notification: #{e.message}"
  end

  def notify_status_change
    if saved_change_to_status?
      case status
      when "waiting_payment", "approved"
        notify_approval
      when "final_approved"
        notify_final_approval if saved_change_to_status?(from: "waiting_payment")
      when "rejected"
        notify_rejection
      end
    end
  rescue => e
    Rails.logger.error "Failed to create status change notification: #{e.message}"
  end

  def notify_approval
    if game.fee > 0
      # 유료 경기는 입금 요청 알림
      Notification.create_for_user(
        user,
        "game_payment_requested",
        {
          title: "입금 요청",
          message: "#{game.title} 경기 참가가 승인되었습니다. 참가비 #{game.fee_display}를 입금해주세요.",
          notifiable: game,
          priority: "high"
        }
      )
    else
      # 무료 경기는 바로 승인 알림
      Notification.create_for_user(
        user,
        "game_application_approved",
        {
          title: "경기 참가 승인",
          message: "#{game.title} 경기 참가가 승인되었습니다.",
          notifiable: game,
          priority: "high"
        }
      )
    end
  end

  def notify_final_approval
    Notification.create_for_user(
      user,
      "game_payment_confirmed",
      {
        title: "입금 확인 완료",
        message: "#{game.title} 경기 참가비 입금이 확인되었습니다. 경기 참가가 최종 확정되었습니다.",
        notifiable: game,
        priority: "high"
      }
    )
  end

  def notify_rejection
    Notification.create_for_user(
      user,
      "game_application_rejected",
      {
        title: "경기 참가 거절",
        message: "#{game.title} 경기 참가 신청이 거절되었습니다.",
        notifiable: game,
        priority: "normal"
      }
    )
  end
end
