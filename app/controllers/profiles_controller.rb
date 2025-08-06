class ProfilesController < ApplicationController
  before_action :require_login
  before_action :set_user

  def show
    @profile_completion = @user.profile_completion_percentage
    @organized_games = @user.organized_games.includes(:court, :game_applications).order(scheduled_at: :desc).limit(10)
    @recent_applications = @user.game_applications.includes(:game).order(created_at: :desc).limit(5)
    @rating_histories = @user.user_rating_histories.includes(:game).recent.limit(10)

    # 업적 관련 데이터
    @achievements = Achievement.all
    @user_achievements = @user.user_achievements.includes(:achievement)
    @unlocked_achievement_ids = @user_achievements.pluck(:achievement_id)
    @achievements_by_category = @achievements.group_by(&:category)

    # 업적 진행률
    @total_achievements_count = @achievements.count
    @unlocked_achievements_count = @user_achievements.count
    @achievement_progress = @total_achievements_count > 0 ? (@unlocked_achievements_count.to_f / @total_achievements_count * 100).round : 0

    # 최근 획득한 업적
    @recent_achievement = @user_achievements.order(created_at: :desc).first

    # 포인트 통계
    @points_this_month = @user.user_points.where(earned_at: Date.current.beginning_of_month..Date.current.end_of_month).sum(:points) if @user.user_points.any?
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: "프로필이 업데이트되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def stats
    @games_played = @user.games.count
    @games_organized = @user.organized_games.count
    @total_applications = @user.game_applications.count
    @approved_applications = @user.game_applications.approved.count
  end

  def history
    @games = @user.games.includes(:court).order(scheduled_at: :desc).limit(20)
    @organized_games = @user.organized_games.includes(:court).order(scheduled_at: :desc).limit(20)
    @applications = @user.game_applications.includes(:game, :user).order(created_at: :desc).limit(20)
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :nickname, :real_name,
                                 :height, :weight, :city, :district, :team_name,
                                 :bio, :bank_name, :account_number, :account_holder,
                                 positions: [])
  end
end
