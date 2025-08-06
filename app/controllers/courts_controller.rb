class CourtsController < ApplicationController
  before_action :set_court, only: [ :show, :realtime ]

  def index
    @courts = Court.all

    # 필터링 옵션
    if params[:court_type].present?
      @courts = @courts.where(court_type: params[:court_type])
    end

    if params[:search].present?
      @courts = @courts.where("name LIKE ? OR address LIKE ?",
                              "%#{params[:search]}%",
                              "%#{params[:search]}%")
    end

    # 위치 기반 검색
    if params[:lat].present? && params[:lng].present?
      @courts = @courts.nearby(params[:lat], params[:lng], params[:radius] || 10)
    end

    # 페이지네이션
    @courts = @courts.page(params[:page]).per(12)
  end

  def show
    # 최근 게임들
    @recent_games = @court.games.includes(:organizer, :players)
                           .where("scheduled_at >= ?", Date.today)
                           .order(scheduled_at: :asc)
                           .limit(5)

    # 코트 통계
    @total_games = @court.games.count
    @active_players = @court.games.joins(:players).distinct.count("users.id")

    # 방문 기록 업데이트 (로그인한 사용자만)
    if logged_in?
      visit = CourtVisit.find_or_create_by(user: current_user, court: @court)
      visit.update(last_visited_at: Time.current, visit_count: visit.visit_count + 1)
    end
  end

  def realtime
    # 실시간 정보가 활성화된 코트만
    unless @court.realtime_enabled?
      redirect_to @court, alert: "이 코트는 실시간 정보를 지원하지 않습니다."
      return
    end

    # 최근 활동 내역
    @recent_activities = @court.court_activities
                              .includes(:user)
                              .recent
                              .limit(20)

    # 오늘의 활동 통계
    @today_stats = {
      total_players: @court.court_activities.today.sum(:player_count),
      peak_time: find_peak_time_today,
      busiest_hour: @court.peak_hours.max_by { |k, v| v }&.first || "N/A"
    }

    # 현재 체크인한 사용자들
    check_in_users = @court.court_activities
                          .where("recorded_at > ?", 2.hours.ago)
                          .by_type("check_in")
                          .pluck(:user_id)

    check_out_users = @court.court_activities
                           .where("recorded_at > ?", 2.hours.ago)
                           .by_type("check_out")
                           .pluck(:user_id)

    @active_user_ids = check_in_users - check_out_users
    @active_users = User.where(id: @active_user_ids) if @active_user_ids.any?
  end

  private

  def find_peak_time_today
    today_activities = @court.court_activities.today
                            .group_by { |a| a.recorded_at.hour }
                            .transform_values { |activities| activities.sum(&:player_count) }

    peak_hour = today_activities.max_by { |_, count| count }&.first
    peak_hour ? "#{peak_hour}:00" : "N/A"
  end

  def set_court
    @court = Court.find(params[:id])
  end

  def court_params
    params.require(:court).permit(:name, :address, :latitude, :longitude,
                                   :court_type, :capacity, :water_fountain,
                                   :shower_available, :parking_available,
                                   :smoking_allowed, :air_conditioning,
                                   :locker_room, :equipment_rental,
                                   :image1, :image2)
  end
end
