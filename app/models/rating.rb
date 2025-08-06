class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :game
  belongs_to :rated_user, class_name: "User"

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :rating_type, presence: true, inclusion: { in: %w[player host] }
  validates :user_id, uniqueness: { scope: [ :game_id, :rated_user_id ] }

  # Scopes
  scope :for_host, -> { where(rating_type: "host") }
  scope :for_player, -> { where(rating_type: "player") }
  scope :recent, -> { order(created_at: :desc) }
  scope :this_month, -> { where(created_at: Date.current.beginning_of_month..Date.current.end_of_month) }

  # Class methods
  def self.average_rating_for_user(user_id)
    ratings = where(rated_user_id: user_id)
    # 평점이 없으면 기본값 2.5 (50%)
    ratings.any? ? ratings.average(:rating) : 2.5
  end

  def self.rating_count_for_user(user_id)
    where(rated_user_id: user_id).count
  end

  # Instance methods
  def rating_percentage
    (rating.to_f / 5.0 * 100).round
  end
end
