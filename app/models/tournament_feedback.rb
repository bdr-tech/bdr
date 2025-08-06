class TournamentFeedback < ApplicationRecord
  belongs_to :tournament
  belongs_to :user

  validates :overall_rating, presence: true, inclusion: { in: 1..5 }

  scope :positive, -> { where("overall_rating >= ?", 4) }
  scope :recent, -> { order(created_at: :desc) }

  def positive?
    overall_rating >= 4
  end

  def self.average_rating
    average(:overall_rating)&.round(1) || 0
  end

  def self.participation_rate
    where(would_participate_again: true).count.to_f / count * 100
  end
end
