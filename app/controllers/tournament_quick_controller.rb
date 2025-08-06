class TournamentQuickController < ApplicationController
  before_action :authenticate_user!
  before_action :require_premium_user
  before_action :set_wizard, only: %i[show update previous]
  before_action :set_tournament, only: %i[preview publish share]

  # 대회 템플릿 선택 화면
  def templates
    @templates = tournament_templates
  end

  # 마법사 진행
  def show
    @wizard = current_user.tournament_wizards.find_or_create_by(completed: false)
    render "tournament_quick/steps/#{@wizard.step}"
  end

  # 마법사 업데이트
  def update
    @wizard.wizard_data.merge!(wizard_params)
    @wizard.save!

    if params[:commit] == "다음"
      if @wizard.step == "review"
        create_tournament_from_wizard
      else
        @wizard.next_step!
        redirect_to tournament_quick_path
      end
    else
      redirect_to tournament_quick_path
    end
  end

  # 이전 단계로
  def previous
    @wizard.previous_step!
    redirect_to tournament_quick_path
  end

  # 미리보기
  def preview
    render layout: "tournament_preview"
  end

  # 발행
  def publish
    if @tournament.update(status: "published")
      generate_share_links
      send_notifications
      redirect_to tournament_path(@tournament), notice: "대회가 성공적으로 발행되었습니다!"
    else
      redirect_to preview_tournament_quick_path(@tournament), alert: "발행 중 오류가 발생했습니다."
    end
  end

  # 공유
  def share
    @share_links = @tournament.tournament_share_links
    @qr_code = generate_qr_code(@tournament)
  end

  private

  def set_wizard
    @wizard = current_user.tournament_wizards.find_by(completed: false)
    redirect_to templates_tournament_quick_index_path if @wizard.nil?
  end

  def set_tournament
    @tournament = current_user.organized_tournaments.find(params[:id])
  end

  def require_premium_user
    unless current_user.is_premium?
      redirect_to premium_path, alert: "대회 기능은 프리미엄 회원만 사용 가능합니다."
    end
  end

  def wizard_params
    params.require(:wizard).permit!
  end

  def create_tournament_from_wizard
    data = @wizard.wizard_data

    tournament = current_user.organized_tournaments.build(
      name: data["name"],
      description: data["description"],
      tournament_type: data["tournament_type"] || "single_elimination",
      game_type: data["game_type"] || "5x5",
      min_teams: data["min_teams"] || 4,
      max_teams: data["max_teams"] || 8,
      players_per_team: data["players_per_team"] || 5,
      entry_fee: data["entry_fee"] || 0,
      tournament_start_at: data["start_datetime"],
      tournament_end_at: data["end_datetime"],
      registration_start_at: Time.current,
      registration_end_at: data["start_datetime"] - 1.day,
      venue_name: data["venue_name"],
      venue_address: data["venue_address"],
      template_type: data["template_type"],
      is_quick_tournament: true,
      auto_bracket_generation: true,
      auto_score_calculation: true,
      mobile_optimized: true,
      prizes_info: data["prizes_info"] || {},
      special_events: data["special_events"] || [],
      budget_settings: calculate_budget(data),
      status: "draft"
    )

    if tournament.save
      @wizard.update!(tournament: tournament, completed: true)
      generate_poster(tournament) if data["generate_poster"]
      redirect_to preview_tournament_quick_path(tournament)
    else
      flash.now[:alert] = tournament.errors.full_messages.join(", ")
      render "tournament_quick/steps/review"
    end
  end

  def tournament_templates
    [
      {
        id: "saturday_afternoon",
        name: "토요일 오후 토너먼트",
        description: "8팀 싱글 엘리미네이션, 오후 2시~6시",
        icon: "🏆",
        settings: {
          tournament_type: "single_elimination",
          max_teams: 8,
          duration: 4,
          entry_fee: 20000
        }
      },
      {
        id: "3x3_lightning",
        name: "3x3 번개 대회",
        description: "4~8팀, 2시간 완성, 라운드 로빈",
        icon: "⚡",
        settings: {
          tournament_type: "round_robin",
          game_type: "3x3",
          max_teams: 8,
          duration: 2,
          entry_fee: 10000
        }
      },
      {
        id: "company_friendly",
        name: "회사 동료 친선대회",
        description: "부서별 대항전, 순위 상관없이 모두 상품",
        icon: "🤝",
        settings: {
          tournament_type: "round_robin",
          max_teams: 6,
          duration: 6,
          entry_fee: 0
        }
      },
      {
        id: "monthly_club",
        name: "동호회 월례 대회",
        description: "매달 마지막 주, 실력 균등 분배",
        icon: "📅",
        settings: {
          tournament_type: "group_stage",
          max_teams: 12,
          duration: 8,
          entry_fee: 0
        }
      }
    ]
  end

  def calculate_budget(data)
    teams = data["max_teams"].to_i
    entry_fee = data["entry_fee"].to_i

    income = teams * entry_fee
    platform_fee = income * 0.05

    {
      expected_income: income,
      platform_fee: platform_fee,
      net_income: income - platform_fee,
      court_fee: data["court_fee"] || 50000,
      prize_budget: data["prize_budget"] || 50000,
      refreshment_budget: data["refreshment_budget"] || 30000
    }
  end

  def generate_poster(tournament)
    TournamentPosterService.new(tournament).generate_async
  end

  def generate_share_links
    %w[kakao instagram general].each do |type|
      @tournament.tournament_share_links.create!(
        share_type: type,
        full_url: tournament_url(@tournament)
      )
    end
  end

  def generate_qr_code(tournament)
    qr_url = tournament_check_in_url(tournament)
    RQRCode::QRCode.new(qr_url).as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true
    )
  end

  def send_notifications
    TournamentNotificationJob.perform_later(@tournament.id, "published")
  end
end
