class PointsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @total_points = @user.total_points || 0

    # 포인트 내역 (페이지네이션)
    @points = @user.user_points.order(earned_at: :desc).page(params[:page]).per(20)

    # 월별 포인트 통계
    @monthly_stats = calculate_monthly_stats

    # 포인트 순위
    @user_rank = User.where("total_points > ?", @total_points).count + 1
    @top_users = User.where("total_points > 0").order(total_points: :desc).limit(10)

    # 포인트 획득 방법
    @point_rules = {
      "경기 참가 완료" => 50,
      "경기 평가 완료" => 10,
      "첫 경기 참가" => 100,
      "10회 경기 참가" => 200,
      "호스트 평가 우수" => 30,
      "프리미엄 가입" => 500,
      "친구 초대" => 100
    }
  end

  private

  def calculate_monthly_stats
    # 최근 6개월 통계
    stats = []
    6.times do |i|
      date = i.months.ago
      month_start = date.beginning_of_month
      month_end = date.end_of_month

      points_earned = @user.user_points
                           .where(earned_at: month_start..month_end)
                           .sum(:points)

      stats << {
        month: date.strftime("%Y년 %m월"),
        points: points_earned
      }
    end

    stats.reverse
  end
end
