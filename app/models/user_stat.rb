class UserStat < ApplicationRecord
  belongs_to :user

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :wins, :losses, :games_played, :mvp_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def win_rate
    return 0 if games_played == 0
    (wins.to_f / games_played * 100).round(1)
  end

  def loss_rate
    return 0 if games_played == 0
    (losses.to_f / games_played * 100).round(1)
  end

  def total_games
    wins + losses
  end
end
