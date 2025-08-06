class UserPoint < ApplicationRecord
  belongs_to :user

  # Validations
  validates :points, presence: true, numericality: { other_than: 0 }
  validates :description, presence: true
  validates :transaction_type, presence: true, inclusion: { in: %w[earned used expired promotion] }

  # Scopes
  scope :earned, -> { where(transaction_type: "earned") }
  scope :used, -> { where(transaction_type: "used") }
  scope :expired, -> { where(transaction_type: "expired") }
  scope :promotion, -> { where(transaction_type: "promotion") }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :update_user_total_points

  private

  def update_user_total_points
    case transaction_type
    when "earned", "promotion"
      user.increment!(:total_points, points)
    when "used", "expired"
      user.decrement!(:total_points, points.abs)
    end
  end
end
