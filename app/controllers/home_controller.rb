class HomeController < ApplicationController
  def index
    @upcoming_games = Game.upcoming.includes(:court, :organizer).limit(5)
    @nearby_courts = Court.includes(:games).limit(3)
    @quick_stats = Rails.cache.fetch("home_quick_stats", expires_in: 1.hour) do
      {
        total_games: Game.count,
        active_players: User.count,
        courts_available: Court.count
      }
    end
    @recent_posts = Post.includes(:user).recent.limit(5)
    @recent_activities = Activity.includes(:user, :trackable).recent.limit(10)
  end
end
