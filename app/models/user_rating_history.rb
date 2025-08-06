class UserRatingHistory < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :rating_before, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :rating_after, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :rating_change, presence: true
  validates :evaluation_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  def positive_change?
    rating_change > 0
  end

  def negative_change?
    rating_change < 0
  end
end
