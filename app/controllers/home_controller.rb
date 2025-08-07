class HomeController < ApplicationController
  skip_before_action :require_login, only: [:index]
  
  def index
    # Cache home page data for 5 minutes
    @upcoming_games = Rails.cache.fetch("home/upcoming_games", expires_in: 5.minutes) do
      Game.upcoming
          .includes(:court, :organizer, :players)
          .limit(6)
          .to_a
    end
    
    @nearby_courts = Rails.cache.fetch("home/nearby_courts", expires_in: 10.minutes) do
      Court.available
           .includes(:games)
           .limit(4)
           .to_a
    end
    
    @quick_stats = Rails.cache.fetch("home/quick_stats", expires_in: 10.minutes) do
      {
        total_games: Game.count,
        active_players: User.active.count,
        courts_available: Court.available.count
      }
    end
    
    @recent_posts = Rails.cache.fetch("home/recent_posts", expires_in: 5.minutes) do
      # Will be implemented when Post model is ready
      []
    end
    
    @recent_activities = Rails.cache.fetch("home/recent_activities", expires_in: 5.minutes) do
      # Will be implemented when activity tracking is ready
      []
    end
  end
end
