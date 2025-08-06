class BillingKey < ApplicationRecord
  belongs_to :user

  validates :customer_key, presence: true, uniqueness: true
  validates :billing_key, presence: true, uniqueness: true
  validates :card_number, presence: true

  scope :active, -> { where(is_active: true) }

  def self.generate_customer_key(user_id)
    # 안전한 customer key 생성 (유추 불가능)
    "CUS_#{SecureRandom.hex(8)}_#{user_id}_#{Time.current.to_i}"
  end

  def deactivate!
    update!(is_active: false)
  end

  def use!
    update!(last_used_at: Time.current)
  end
end
