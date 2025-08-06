class SeasonAverage < ApplicationRecord
  belongs_to :user

  validates :season_name, presence: true
  validates :season_name, uniqueness: { scope: :user_id }

  # Recalculate averages based on PlayerStats
  def recalculate!
    stats = user.player_stats
                .joins(:game)
                .where("games.scheduled_at >= ? AND games.scheduled_at <= ?", season_start, season_end)

    return if stats.empty?

    total_games = stats.count
    total_minutes = stats.sum(:minutes_played)

    self.games_played = total_games
    self.minutes_per_game = total_minutes.to_f / total_games
    self.points_per_game = stats.average(:points) || 0
    self.rebounds_per_game = stats.average(:total_rebounds) || 0
    self.assists_per_game = stats.average(:assists) || 0
    self.steals_per_game = stats.average(:steals) || 0
    self.blocks_per_game = stats.average(:blocks) || 0
    self.turnovers_per_game = stats.average(:turnovers) || 0

    # Calculate shooting percentages
    total_fgm = stats.sum(:field_goals_made)
    total_fga = stats.sum(:field_goals_attempted)
    self.field_goal_percentage = total_fga > 0 ? (total_fgm.to_f / total_fga * 100) : 0

    total_3pm = stats.sum(:three_pointers_made)
    total_3pa = stats.sum(:three_pointers_attempted)
    self.three_point_percentage = total_3pa > 0 ? (total_3pm.to_f / total_3pa * 100) : 0

    total_ftm = stats.sum(:free_throws_made)
    total_fta = stats.sum(:free_throws_attempted)
    self.free_throw_percentage = total_fta > 0 ? (total_ftm.to_f / total_fta * 100) : 0

    # Calculate advanced stats
    total_points = stats.sum(:points)
    total_shooting_possessions = total_fga + 0.44 * total_fta
    self.true_shooting_percentage = total_shooting_possessions > 0 ?
      (total_points.to_f / (2 * total_shooting_possessions) * 100) : 0

    # Win/Loss record
    wins_count = 0
    stats.each do |stat|
      if stat.game_result && stat.game_result.winner_team_id
        # Check if user was on winning team
        winning_team = stat.game.game_players.find_by(user: user)&.team
        wins_count += 1 if winning_team && stat.game_result.winner_team_id == winning_team
      end
    end

    self.wins = wins_count
    self.losses = total_games - wins_count

    save!
  end

  # Get current season name
  def self.current_season_name
    now = Date.current
    year = now.year

    case now.month
    when 1..3
      "#{year} Winter"
    when 4..6
      "#{year} Spring"
    when 7..9
      "#{year} Summer"
    when 10..12
      "#{year} Fall"
    end
  end

  # Find or create current season for user
  def self.find_or_create_current_season(user)
    season_name = current_season_name
    now = Date.current

    season_start = case now.month
    when 1..3
      Date.new(now.year, 1, 1)
    when 4..6
      Date.new(now.year, 4, 1)
    when 7..9
      Date.new(now.year, 7, 1)
    when 10..12
      Date.new(now.year, 10, 1)
    end

    season_end = season_start + 3.months - 1.day

    find_or_create_by(user: user, season_name: season_name) do |season|
      season.season_start = season_start
      season.season_end = season_end
    end
  end
end
