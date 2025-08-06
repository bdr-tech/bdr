class PremiumSubscription < ApplicationRecord
  belongs_to :user

  validates :plan_type, presence: true, inclusion: { in: %w[monthly yearly lifetime] }
  validates :payment_key, presence: true, uniqueness: true
  validates :order_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[active cancelled expired refunded] }

  scope :active, -> { where(status: "active") }
  scope :recent, -> { order(created_at: :desc) }

  def cancel!
    return false unless status == "active"

    transaction do
      update!(status: "cancelled", cancelled_at: Time.current)

      # Update user premium status
      user.update!(
        is_premium: false,
        premium_type: nil,
        premium_expires_at: nil
      )
    end

    true
  end

  def refund!(refund_amount = nil)
    return false unless %w[active cancelled].include?(status)

    refund_amount ||= amount

    # Process refund through TossPayments
    toss_client = TossPaymentsClient.new
    result = toss_client.cancel_payment(
      payment_key: payment_key,
      cancel_reason: "Customer requested refund",
      cancel_amount: refund_amount
    )

    if result["status"] == "CANCELED"
      update!(
        status: "refunded",
        refunded_at: Time.current,
        refund_amount: refund_amount
      )
      true
    else
      false
    end
  end
end
