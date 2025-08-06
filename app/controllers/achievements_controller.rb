class AchievementsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
    @achievements = Achievement.all.includes(:user_achievements)
    @user_achievements = @user.user_achievements.includes(:achievement)
    @unlocked_achievement_ids = @user_achievements.pluck(:achievement_id)

    # 업적 카테고리별 그룹화
    @achievements_by_category = @achievements.group_by(&:category)

    # 업적 진행률
    @total_achievements = @achievements.count
    @unlocked_count = @user_achievements.count
    @progress_percentage = @total_achievements > 0 ? (@unlocked_count.to_f / @total_achievements * 100).round : 0

    # 최근 획득한 업적
    @recent_achievements = @user_achievements.order(created_at: :desc).limit(5)

    # 포인트 통계
    @total_points = @user.total_points || 0
    @points_this_month = @user.user_points.where(earned_at: Date.current.beginning_of_month..Date.current.end_of_month).sum(:points)
    @points_history = @user.user_points.order(earned_at: :desc).limit(10)
  end

  def show
    @achievement = Achievement.find(params[:id])
    @users_with_achievement = User.joins(:user_achievements)
                                  .where(user_achievements: { achievement_id: @achievement.id })
                                  .order("user_achievements.created_at DESC")
                                  .limit(10)

    @total_users_with_achievement = @achievement.user_achievements.count
    @user_has_achievement = current_user.user_achievements.exists?(achievement_id: @achievement.id)

    if @user_has_achievement
      @user_achievement = current_user.user_achievements.find_by(achievement_id: @achievement.id)
    end
  end
end
