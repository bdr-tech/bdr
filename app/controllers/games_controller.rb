class GamesController < ApplicationController
  before_action :require_login, only: [ :show, :new, :create, :edit, :update, :destroy, :join, :leave, :quick_join, :confirm_join, :apply, :cancel_application, :approve_application, :reject_application, :confirm_payment, :duplicate ]
  before_action :set_game, only: [ :show, :edit, :update, :destroy, :join, :leave, :quick_join, :confirm_join, :apply, :cancel_application, :approve_application, :reject_application, :confirm_payment, :duplicate ]
  before_action :check_organizer, only: [ :edit, :update, :destroy, :duplicate ]

  def index
    # 캐시 키 생성
    cache_key = [
      "games",
      params[:show_past],
      params[:court_type],
      params[:date],
      params[:city],
      params[:district],
      Game.maximum(:updated_at)&.to_i
    ].join("/")
    
    @games = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      games = if params[:show_past] == "true"
        Game.includes(:court, :organizer, :players)
      else
        Game.upcoming.includes(:court, :organizer, :players)
      end

      games = games.joins(:court).where(courts: { court_type: params[:court_type] }) if params[:court_type].present?
      games = games.where("scheduled_at >= ? AND scheduled_at <= ?", params[:date], params[:date].to_date.end_of_day) if params[:date].present?

      # 지역 필터링
      if params[:city].present?
        games = games.where(city: params[:city])
        if params[:district].present?
          games = games.where(district: params[:district])
        end
      end

      games.order(scheduled_at: :asc).limit(20).to_a
    end

    # Location 데이터 캐싱 사용
    location_data = cached_location_data
    @cities = location_data[:cities]
    @locations = location_data[:by_city]
  end

  def show
    # N+1 쿼리 해결: 한 번에 모든 연관 데이터 로드
    @game = Game.includes(:court, :organizer, :players, game_applications: :user).find(@game.id)
    @can_join = @game.players.count < @game.max_players
    @current_players = @game.players
    @pending_applications = @game.game_applications.pending
  end

  def new
    unless current_user.can_create_more_games?
      redirect_to games_path, alert: "동시에 주최할 수 있는 경기 수(#{current_user.max_concurrent_games}개)를 초과했습니다."
      return
    end

    @game = Game.new
    @cities = Location.distinct.pluck(:city).sort
    @locations = Location.all.group_by(&:city)
  end

  def create
    @game = Game.new(game_params)
    @game.organizer = current_user || User.first  # 로그인 구현 후 current_user 사용

    if @game.save
      redirect_to @game, notice: "🎉 경기가 성공적으로 생성되었습니다! 참가자들을 기다려보세요."
    else
      @cities = Location.distinct.pluck(:city).sort
      @locations = Location.all.group_by(&:city)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @cities = Location.distinct.pluck(:city).sort
    @locations = Location.all.group_by(&:city)
  end

  def update
    if @game.update(game_params)
      redirect_to @game, notice: "경기가 성공적으로 수정되었습니다."
    else
      @cities = Location.distinct.pluck(:city).sort
      @locations = Location.all.group_by(&:city)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path, notice: "경기가 삭제되었습니다."
  end

  def today
    @games = Game.today.includes(:court, :organizer, :players)
  end

  def nearby
    @games = Game.upcoming.includes(:court, :organizer, :players).limit(15)
    # TODO: Implement actual GPS-based filtering
  end

  def join
    # TODO: Add authentication check
    # return redirect_to login_path unless current_user

    if @game.players.count >= @game.max_players
      redirect_to @game, alert: "이미 정원이 찼습니다."
      return
    end

    # participation = @game.game_participations.build(user: current_user)
    # if participation.save
    #   redirect_to @game, notice: '게임에 참가하였습니다.'
    # else
    #   redirect_to @game, alert: '참가에 실패했습니다.'
    # end

    redirect_to @game, notice: "게임 참가 기능은 사용자 인증 후 사용 가능합니다."
  end

  def leave
    # TODO: Implement leave functionality
    redirect_to @game, notice: "게임에서 나왔습니다."
  end

  # 3-Second Rule: Step 1 - Quick Match
  def quick_match
    @nearby_games = Game.upcoming
                       .joins(:court)
                       .where("scheduled_at >= ? AND scheduled_at <= ?",
                              Time.current, 1.day.from_now)
                       .where("(SELECT COUNT(*) FROM game_participations WHERE game_id = games.id) < max_players")
                       .includes(:court, :organizer)
                       .limit(5)

    # 모든 코트 데이터를 전달 (GPS 거리 계산용)
    @courts = Court.all.select(:id, :name, :address, :latitude, :longitude, :court_type, :capacity,
                               :parking_available, :water_fountain, :shower_available, :air_conditioning)
  end

  # 3-Second Rule: Step 2 - Quick Join
  def quick_join
    @available_spots = @game.max_players - @game.players.count
  end

  # 3-Second Rule: Step 3 - Confirm Join
  def confirm_join
    # TODO: Implement actual join logic with authentication
    redirect_to @game, notice: "⚡ 3초 룰 완료! 게임에 참가했습니다."
  end

  def apply
    unless logged_in?
      redirect_to login_path, alert: "로그인이 필요합니다."
      return
    end

    unless current_user.can_apply_for_games?
      hours_left = current_user.cancellation_hours_until_reset
      redirect_to @game, alert: "취소 횟수 제한으로 인해 #{hours_left}시간 후 신청이 가능합니다."
      return
    end

    unless current_user.can_participate_in_games?
      redirect_to @game, alert: "프로필을 완성해주세요."
      return
    end

    unless @game.can_accept_players?
      redirect_to @game, alert: "이미 정원이 마감되었습니다."
      return
    end

    # 중복 신청 체크
    if @game.game_applications.exists?(user: current_user)
      redirect_to @game, alert: "이미 신청한 경기입니다."
      return
    end

    application = @game.game_applications.build(
      user: current_user,
      status: "pending",
      message: params[:message]
    )

    if application.save
      redirect_to @game, notice: "경기 참가 신청이 완료되었습니다. 주최자의 승인을 기다려주세요."
    else
      redirect_to @game, alert: "신청에 실패했습니다. 다시 시도해주세요."
    end
  end

  def cancel_application
    application = @game.game_applications.find_by(user: current_user)

    unless application
      redirect_to @game, alert: "신청 내역이 없습니다."
      return
    end

    application.cancel!
    redirect_to @game, notice: "경기 신청이 취소되었습니다."
  end

  def approve_application
    unless @game.organizer == current_user || current_user.admin?
      redirect_to @game, alert: "권한이 없습니다."
      return
    end

    application = @game.game_applications.find(params[:application_id])
    application.approve!

    # 승인 이메일 발송
    UserMailer.application_approved(application).deliver_later

    redirect_to @game, notice: "#{application.user.nickname || application.user.name}님의 신청을 승인했습니다."
  end

  def reject_application
    unless @game.organizer == current_user || current_user.admin?
      redirect_to @game, alert: "권한이 없습니다."
      return
    end

    application = @game.game_applications.find(params[:application_id])
    application.reject!

    # 거절 이메일 발송
    UserMailer.application_rejected(application).deliver_later

    redirect_to @game, notice: "#{application.user.nickname || application.user.name}님의 신청을 거절했습니다."
  end

  def confirm_payment
    unless @game.organizer == current_user || current_user.admin?
      redirect_to @game, alert: "권한이 없습니다."
      return
    end

    application = @game.game_applications.find(params[:application_id])

    if application.confirm_payment!
      redirect_to @game, notice: "#{application.user.nickname || application.user.name}님의 입금을 확인했습니다. 최종 승인되었습니다."
    else
      redirect_to @game, alert: "입금 확인에 실패했습니다."
    end
  end

  def nearby
    # TODO: Implement GPS-based nearby games
    @games = Game.upcoming.includes(:court, :organizer).limit(10)

    # 지역 데이터 전달 (index와 동일하게)
    @cities = Location.distinct.pluck(:city).sort
    @locations = Location.all.group_by(&:city)

    render :index
  end

  def today
    @games = Game.today.includes(:court, :organizer, :players)

    # 지역 데이터 전달 (index와 동일하게)
    @cities = Location.distinct.pluck(:city).sort
    @locations = Location.all.group_by(&:city)

    render :index
  end

  # 경기 복사 기능
  def duplicate
    new_game = @game.duplicate_for_host(current_user)

    if new_game.save
      redirect_to edit_game_path(new_game), notice: "경기가 복사되었습니다. 날짜와 시간을 설정해주세요."
    else
      redirect_to games_path, alert: "경기 복사에 실패했습니다."
    end
  end

  private

  def set_game
    @game = Game.includes(:court, :organizer).find_by(game_id: params[:id])
    if @game.nil?
      begin
        @game = Game.includes(:court, :organizer).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to games_path, alert: "경기를 찾을 수 없습니다."
        nil
      end
    end
  end

  def check_organizer
    unless @game.organizer == current_user || current_user.admin?
      redirect_to @game, alert: "권한이 없습니다."
    end
  end

  def game_params
    params.require(:game).permit(
      # 1단계
      :game_type, :team_name, :city, :district,
      # 2단계
      :title, :venue_name, :venue_address, :scheduled_at, :start_time, :end_time,
      :max_players, :level, :fee, :description,
      # 3단계
      :parking_required, :shower_required, :water_fountain_required,
      :air_conditioning_required, :message,
      # 유니폼 색상 (배열)
      uniform_colors: []
    )
  end
end
