class TournamentLiveController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament
  before_action :authorize_live_update, only: %i[update_score update_match]

  # 실시간 대회 현황 대시보드
  def dashboard
    @matches = @tournament.tournament_matches.includes(:team_a, :team_b)
    @current_matches = @matches.where(status: "ongoing")
    @upcoming_matches = @matches.where(status: "scheduled").limit(5)
    @recent_updates = @tournament.tournament_live_updates.recent.limit(10)
    @checked_in_count = @tournament.tournament_check_ins.checked_in.count
  end

  # 모바일 점수 입력
  def score_board
    @match = @tournament.tournament_matches.find(params[:match_id])
    render layout: "mobile"
  end

  # 점수 업데이트
  def update_score
    @match = @tournament.tournament_matches.find(params[:match_id])

    ActiveRecord::Base.transaction do
      @match.update!(
        team_a_score: params[:team_a_score],
        team_b_score: params[:team_b_score]
      )

      @tournament.tournament_live_updates.create!(
        tournament_match: @match,
        user: current_user,
        update_type: "score_update",
        data: {
          team_a_score: params[:team_a_score],
          team_b_score: params[:team_b_score],
          quarter: params[:quarter]
        },
        is_official: can_make_official_update?
      )
    end

    respond_to do |format|
      format.json { render json: { success: true, match: @match } }
      format.html { redirect_to tournament_live_dashboard_path(@tournament) }
    end
  end

  # 경기 상태 업데이트
  def update_match
    @match = @tournament.tournament_matches.find(params[:match_id])

    case params[:action_type]
    when "start"
      start_match(@match)
    when "end"
      end_match(@match)
    when "quarter_end"
      quarter_end(@match)
    end

    respond_to do |format|
      format.json { render json: { success: true, match: @match } }
      format.html { redirect_to tournament_live_dashboard_path(@tournament) }
    end
  end

  # QR 체크인
  def check_in
    check_in = @tournament.tournament_check_ins.find_by(qr_code: params[:qr_code])

    if check_in && !check_in.checked_in?
      check_in.check_in!(request.user_agent)
      flash[:notice] = "#{check_in.user.name}님 체크인 완료!"
    else
      flash[:alert] = "유효하지 않은 QR 코드이거나 이미 체크인하셨습니다."
    end

    redirect_to tournament_live_dashboard_path(@tournament)
  end

  # 실시간 피드
  def feed
    @updates = @tournament.tournament_live_updates
                         .includes(:user, :tournament_match)
                         .recent
                         .page(params[:page])

    respond_to do |format|
      format.html { render partial: "feed_items", locals: { updates: @updates } }
      format.json { render json: @updates }
    end
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def authorize_live_update
    unless can_update_live?
      redirect_to tournament_path(@tournament), alert: "권한이 없습니다."
    end
  end

  def can_update_live?
    current_user == @tournament.organizer ||
    current_user.admin? ||
    @tournament.tournament_check_ins.where(user: current_user, role: "staff").exists?
  end

  def can_make_official_update?
    current_user == @tournament.organizer || current_user.admin?
  end

  def start_match(match)
    match.update!(status: "ongoing", started_at: Time.current)

    @tournament.tournament_live_updates.create!(
      tournament_match: match,
      user: current_user,
      update_type: "match_start",
      data: {
        teams: [ match.team_a.name, match.team_b.name ]
      },
      is_official: true
    )
  end

  def end_match(match)
    match.update!(
      status: "completed",
      ended_at: Time.current,
      winner: determine_winner(match)
    )

    @tournament.tournament_live_updates.create!(
      tournament_match: match,
      user: current_user,
      update_type: "match_end",
      data: {
        final_score: "#{match.team_a_score} - #{match.team_b_score}",
        winner: match.winner.name
      },
      is_official: true
    )

    # 다음 라운드 진출 처리
    TournamentBracketService.new(@tournament).advance_winner(match)
  end

  def quarter_end(match)
    @tournament.tournament_live_updates.create!(
      tournament_match: match,
      user: current_user,
      update_type: "quarter_end",
      data: {
        quarter: params[:quarter],
        score: "#{match.team_a_score} - #{match.team_b_score}"
      },
      is_official: true
    )
  end

  def determine_winner(match)
    if match.team_a_score > match.team_b_score
      match.team_a
    else
      match.team_b
    end
  end
end
