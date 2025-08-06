class StatsController < ApplicationController
  before_action :require_login
  before_action :require_premium!
  before_action :set_user, only: [ :show ]

  def index
    @user = current_user
    @current_season = @user.current_season_stats
    @career_stats = @user.career_stats
    @recent_games = @user.player_stats.includes(:game).order(created_at: :desc).limit(10)
    @all_seasons = @user.season_averages.order(season_start: :desc)

    # Calculate best performances
    @best_performances = {
      points: @user.player_stats.order(points: :desc).first,
      rebounds: @user.player_stats.order(total_rebounds: :desc).first,
      assists: @user.player_stats.order(assists: :desc).first,
      steals: @user.player_stats.order(steals: :desc).first,
      blocks: @user.player_stats.order(blocks: :desc).first
    }

    # Get monthly stats for chart
    @monthly_stats = calculate_monthly_stats
  end

  def show
    unless @user.premium?
      redirect_to user_path(@user), alert: "이 페이지는 프리미엄 회원만 볼 수 있습니다."
      return
    end

    @current_season = @user.current_season_stats
    @career_stats = @user.career_stats
    @recent_games = @user.player_stats.includes(:game).order(created_at: :desc).limit(5)
  end

  def game_log
    @user = current_user
    @stats = @user.player_stats.includes(:game, game: :court)
                  .order(created_at: :desc)
                  .page(params[:page]).per(20)
  end

  def season
    @user = current_user
    @season = @user.season_averages.find_by(season_name: params[:season_name])

    if @season.nil?
      redirect_to stats_path, alert: "시즌을 찾을 수 없습니다."
      return
    end

    @season_games = @user.player_stats
                         .joins(:game)
                         .where("games.scheduled_at >= ? AND games.scheduled_at <= ?",
                                @season.season_start, @season.season_end)
                         .includes(:game, game: :court)
                         .order("games.scheduled_at DESC")

    # Calculate monthly breakdown
    @monthly_breakdown = calculate_season_monthly_breakdown(@season_games)
  end

  def compare
    @user = current_user
    @compare_user = User.find_by(id: params[:user_id])

    if @compare_user.nil? || !@compare_user.premium?
      redirect_to stats_path, alert: "비교할 수 없는 사용자입니다."
      return
    end

    @user_stats = @user.career_stats
    @compare_stats = @compare_user.career_stats

    # Get head-to-head stats
    @head_to_head = calculate_head_to_head(@user, @compare_user)
  end

  private

  def require_premium!
    unless current_user.premium?
      redirect_to premium_path, alert: "프리미엄 회원만 이용할 수 있는 기능입니다."
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def calculate_monthly_stats
    stats = {}

    6.times do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month

      monthly_data = current_user.player_stats
                                 .joins(:game)
                                 .where("games.scheduled_at >= ? AND games.scheduled_at <= ?",
                                        month_start, month_end)

      if monthly_data.any?
        stats[month_start.strftime("%Y-%m")] = {
          games: monthly_data.count,
          ppg: monthly_data.average(:points) || 0,
          rpg: monthly_data.average(:total_rebounds) || 0,
          apg: monthly_data.average(:assists) || 0,
          fg_pct: calculate_monthly_shooting_percentage(monthly_data, :field_goals),
          three_pct: calculate_monthly_shooting_percentage(monthly_data, :three_pointers)
        }
      end
    end

    stats
  end

  def calculate_monthly_shooting_percentage(stats, type)
    made = stats.sum("#{type}_made")
    attempted = stats.sum("#{type}_attempted")
    return 0.0 if attempted == 0
    (made.to_f / attempted * 100).round(1)
  end

  def calculate_season_monthly_breakdown(season_games)
    breakdown = {}

    season_games.group_by { |stat| stat.game.scheduled_at.beginning_of_month }.each do |month, stats|
      breakdown[month] = {
        games: stats.count,
        ppg: stats.sum(&:points).to_f / stats.count,
        rpg: stats.sum(&:total_rebounds).to_f / stats.count,
        apg: stats.sum(&:assists).to_f / stats.count
      }
    end

    breakdown.sort_by { |month, _| month }
  end

  def calculate_head_to_head(user1, user2)
    # Find games where both users played
    common_games = user1.games & user2.games

    stats = {
      games_played: common_games.count,
      user1_wins: 0,
      user2_wins: 0,
      user1_avg_points: 0,
      user2_avg_points: 0
    }

    return stats if common_games.empty?

    common_games.each do |game|
      user1_stat = game.player_stats.find_by(user: user1)
      user2_stat = game.player_stats.find_by(user: user2)

      next unless user1_stat && user2_stat

      # Determine winner based on team
      user1_team = game.game_players.find_by(user: user1)&.team
      user2_team = game.game_players.find_by(user: user2)&.team

      if game.game_result && user1_team != user2_team
        if game.game_result.winner_team_id == user1_team
          stats[:user1_wins] += 1
        elsif game.game_result.winner_team_id == user2_team
          stats[:user2_wins] += 1
        end
      end
    end

    # Calculate average points in head-to-head games
    user1_h2h_stats = user1.player_stats.joins(:game).where(game: common_games)
    user2_h2h_stats = user2.player_stats.joins(:game).where(game: common_games)

    stats[:user1_avg_points] = user1_h2h_stats.average(:points) || 0
    stats[:user2_avg_points] = user2_h2h_stats.average(:points) || 0

    stats
  end
end
