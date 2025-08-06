class HomeController < ApplicationController
  skip_before_action :require_login, only: [:index]
  
  def index
    # Simplified for initial deployment
    @upcoming_games = []
    @nearby_courts = []
    @quick_stats = {
      total_games: 0,
      active_players: 0,
      courts_available: 0
    }
    @recent_posts = []
    @recent_activities = []
  end
end
