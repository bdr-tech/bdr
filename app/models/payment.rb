class Payment < ApplicationRecord
  include PaymentCalculator

  belongs_to :game_application

  # Delegate associations for easier access
  has_one :user, through: :game_application
  has_one :game, through: :game_application

  # 결제 상태 enum
  enum :status, {
    pending: "pending",           # 입금 대기
    paid: "paid",                # 입금 완료
    transferred: "transferred",   # 호스트에게 송금 완료
    refunded: "refunded",        # 환불 완료
    failed: "failed",            # 결제 실패
    cancelled: "cancelled"       # 결제 취소
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  # Callbacks
  before_create :calculate_fees
  after_update :update_game_revenue, if: :saved_change_to_status?

  # BDR 계좌 정보
  def self.bdr_account_info
    {
      bank_name: "신한은행",
      account_number: "110-123-456789",
      account_holder: "BDR 플랫폼",
      reference_code: "BDR#{Time.current.strftime('%Y%m%d')}"
    }
  end

  # 입금 확인 처리
  def confirm_payment!
    update!(
      status: "paid",
      paid_at: Time.current
    )
  end

  # 호스트에게 송금 처리 (2일 후)
  def transfer_to_host!
    return unless paid? && can_transfer_to_host?

    update!(
      status: "transferred",
      transferred_to_host_at: Time.current
    )
  end

  # 호스트에게 송금 가능한지 확인
  def can_transfer_to_host?
    paid? && paid_at.present? && paid_at <= 2.days.ago
  end

  # 환불 처리
  def refund!
    update!(
      status: "refunded",
      refunded_at: Time.current
    )
  end

  # 플랫폼 수수료 계산
  def platform_fee_amount
    return 0 if amount.nil? || game.nil?
    (amount * game.current_platform_fee_percentage / 100).round(0)
  end

  # 호스트가 받을 순수익
  def host_revenue
    return 0 if amount.nil?
    amount - platform_fee_amount
  end

  private

  # 결제 생성 시 수수료 자동 계산
  def calculate_fees
    self.fee_amount = platform_fee_amount
    self.net_amount = host_revenue
  end

  # 결제 상태 변경 시 게임의 총 수익 업데이트
  def update_game_revenue
    return unless game.present?

    # paid 상태인 결제들의 총액 계산
    total_revenue = game.game_applications
                       .joins(:payment)
                       .where(payments: { status: "paid" })
                       .sum("payments.amount")

    # platform_fee_amount 총액 계산
    total_platform_fee = game.game_applications
                            .joins(:payment)
                            .where(payments: { status: "paid" })
                            .sum("payments.fee_amount")

    # 게임 레코드 업데이트
    game.update_columns(
      revenue_generated: total_revenue,
      platform_fee_amount: total_platform_fee,
      host_payment_amount: total_revenue - total_platform_fee
    )
  end
end
