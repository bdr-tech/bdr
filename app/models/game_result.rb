class GameResult < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :team, presence: true, inclusion: { in: %w[home away] }
  validates :won, inclusion: { in: [ true, false ] }
  validates :player_rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :points_scored, :assists, :rebounds, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :wins, -> { where(won: true) }
  scope :losses, -> { where(won: false) }
  scope :recent, -> { order(created_at: :desc) }

  after_create :update_user_stats
  after_update :update_user_stats

  private

  def update_user_stats
    user.user_stat || user.create_user_stat!
    stats = user.user_stat

    user_results = user.game_results
    stats.update!(
      wins: user_results.wins.count,
      losses: user_results.losses.count,
      games_played: user_results.count,
      rating: user_results.average(:player_rating) || 0.0
    )
  end
end
