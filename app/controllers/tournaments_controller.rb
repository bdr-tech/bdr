class TournamentsController < ApplicationController
  before_action :set_tournament, only: [ :show, :edit, :update, :register ]
  before_action :require_login, only: [ :new, :create, :edit, :update, :register, :create_team ]
  before_action :require_premium_or_admin, only: [ :new, :create, :edit, :update ]
  before_action :check_tournament_owner, only: [ :edit, :update ]

  def new
    @tournament = Tournament.new
    @templates = TournamentTemplate.active.order(:name)

    # 프리미엄 사용자 대회 개최 수 제한 확인
    if current_user.is_premium? && !current_user.admin?
      concurrent_count = current_user.tournaments_as_organizer
                                    .where(status: [ "published", "registration_open", "in_progress" ])
                                    .count

      if concurrent_count >= current_user.max_concurrent_tournaments
        redirect_to tournaments_path, alert: "프리미엄 회원은 동시에 최대 #{current_user.max_concurrent_tournaments}개의 대회만 운영할 수 있습니다."
        nil
      end
    end
  end

  def create
    @tournament = Tournament.new(tournament_params)
    @tournament.organizer = current_user

    # 대회 유형 설정
    if current_user.admin?
      @tournament.is_official = true
      @tournament.status = "published"
      @tournament.approved_at = Time.current
    else
      @tournament.is_official = false
      @tournament.created_by_premium_user = true
      @tournament.status = "published"  # 프리미엄 사용자는 즉시 공개
      @tournament.platform_fee_percentage = 5.0  # 플랫폼 수수료 5%
    end

    # 템플릿 사용 시
    if params[:template_id].present?
      template = TournamentTemplate.find(params[:template_id])
      @tournament.apply_template(template)
      @tournament.template_used = template.name
    end

    if @tournament.save
      # 이미지 첨부
      if params[:tournament][:images].present?
        params[:tournament][:images].each do |image|
          @tournament.images.attach(image) if image.present?
        end
      end

      # 자동화 설정 (프리미엄 사용자 대회만)
      if @tournament.created_by_premium_user?
        TournamentAutomationService.setup_for(@tournament)
      end

      redirect_to @tournament, notice: "대회가 성공적으로 생성되었습니다."
    else
      @templates = TournamentTemplate.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @tournaments = Tournament.includes(:organizer)

    # 필터링
    case params[:filter]
    when "upcoming"
      @tournaments = @tournaments.upcoming
    when "ongoing"
      @tournaments = @tournaments.ongoing
    when "completed"
      @tournaments = @tournaments.completed
    when "registration_open"
      @tournaments = @tournaments.registration_open
    end

    # 검색
    if params[:search].present?
      @tournaments = @tournaments.where("name LIKE ? OR description LIKE ?",
                                      "%#{params[:search]}%",
                                      "%#{params[:search]}%")
    end

    @tournaments = @tournaments.order(tournament_start_at: :asc).page(params[:page]).per(12)

    # 추천 대회
    @featured_tournaments = Tournament.featured.upcoming.limit(3)
  end

  def show
    @tournament.increment!(:view_count)
    @teams = @tournament.tournament_teams.includes(:captain)
    @approved_teams = @teams.approved.order(:seed_number)
    @pending_teams = @teams.pending
    @recent_matches = @tournament.tournament_matches.includes(:home_team, :away_team).completed.order(updated_at: :desc).limit(5)
    @upcoming_matches = @tournament.tournament_matches.includes(:home_team, :away_team).upcoming.limit(5)

    # 현재 사용자의 팀 확인
    if logged_in?
      @user_team = @teams.find_by(captain: current_user)
    end
  end

  def register
    unless @tournament.can_register?
      redirect_to @tournament, alert: "현재 대회 신청이 불가능합니다."
      return
    end

    @team = @tournament.tournament_teams.build
  end

  def create_team
    @tournament = Tournament.find(params[:tournament_id])
    @team = @tournament.tournament_teams.build(team_params)
    @team.captain = current_user
    @team.status = "pending"

    if @team.save
      # 팀원 정보 추가
      if params[:players].present?
        params[:players].each do |player|
          next if player[:name].blank?
          @team.add_player({
            name: player[:name],
            position: player[:position],
            number: player[:number]
          })
        end
        @team.save
      end

      redirect_to @tournament, notice: "대회 신청이 완료되었습니다. 승인을 기다려주세요."
    else
      render :register, status: :unprocessable_entity
    end
  end

  def edit
    @templates = TournamentTemplate.active.order(:name)
  end

  def update
    # 이미지 삭제 처리
    if params[:delete_image_ids].present?
      @tournament.images.where(id: params[:delete_image_ids]).purge
    end

    # 메인 이미지 위치 업데이트
    if params[:tournament][:main_image_position].present?
      @tournament.main_image_position = params[:tournament][:main_image_position].to_i
    end

    if @tournament.update(tournament_params)
      # 새 이미지 추가
      if params[:tournament][:images].present?
        params[:tournament][:images].each do |image|
          @tournament.images.attach(image) if image.present?
        end
      end

      redirect_to @tournament, notice: "대회가 성공적으로 수정되었습니다."
    else
      @templates = TournamentTemplate.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def past
    @tournaments = Tournament.completed.includes(:organizer)
                            .order(tournament_end_at: :desc)
                            .page(params[:page]).per(12)
  end

  def notifications
    if logged_in?
      # 사용자가 참가한 대회의 알림
      @my_tournaments = Tournament.joins(:tournament_teams)
                                 .where(tournament_teams: { captain: current_user })
                                 .distinct

      # 최근 업데이트된 매치
      tournament_ids = @my_tournaments.pluck(:id)
      @recent_updates = TournamentMatch.where(tournament_id: tournament_ids)
                                      .includes(:tournament, :home_team, :away_team)
                                      .order(updated_at: :desc)
                                      .limit(20)
    else
      redirect_to login_path, alert: "로그인이 필요합니다."
    end
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def team_params
    params.require(:tournament_team).permit(:team_name, :contact_phone, :contact_email, :notes)
  end

  def tournament_params
    params.require(:tournament).permit(:name, :description, :venue, :tournament_type,
                                     :max_teams, :entry_fee, :tournament_start_at,
                                     :tournament_end_at, :registration_start_at,
                                     :registration_end_at, :rules, :contact_info,
                                     :is_featured, :prize_info, :auto_bracket_generated,
                                     :auto_notification_enabled, :ai_poster_requested,
                                     :main_image_position, images: [])
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "관리자 권한이 필요합니다."
    end
  end

  def require_premium_or_admin
    unless current_user&.can_create_tournament?
      redirect_to premium_path, alert: "프리미엄 회원(29만원)만 대회를 등록할 수 있습니다. 프리미엄 회원으로 업그레이드하세요."
    end
  end

  def check_tournament_owner
    unless current_user == @tournament.organizer || current_user&.admin?
      redirect_to @tournament, alert: "대회 주최자만 수정할 수 있습니다."
    end
  end
end
