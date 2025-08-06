require "test_helper"

class TournamentQuickControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user.update!(is_premium: true) # 프리미엄 사용자로 설정
    log_in_as(@user)
  end

  test "should redirect non-premium users" do
    @user.update!(is_premium: false)

    get templates_tournament_quick_index_path
    assert_redirected_to premium_path
    assert_equal "대회 기능은 프리미엄 회원만 사용 가능합니다.", flash[:alert]
  end

  test "should show templates for premium users" do
    get templates_tournament_quick_index_path
    assert_response :success
    assert_select "h1", "🏀 간편 대회 만들기"
  end

  test "should create wizard on template selection" do
    assert_difference "TournamentWizard.count", 1 do
      post tournament_quick_index_path, params: { template_id: "saturday_afternoon" }
    end

    wizard = TournamentWizard.last
    assert_equal @user, wizard.user
    assert_equal "template_selection", wizard.step
    assert_not wizard.completed?
  end

  test "should show current wizard step" do
    wizard = TournamentWizard.create!(
      user: @user,
      step: "basic_info",
      wizard_data: { template_type: "saturday_afternoon" }
    )

    get tournament_quick_path
    assert_response :success
    assert_select "h2", "대회 기본 정보"
  end

  test "should update wizard data and move to next step" do
    wizard = TournamentWizard.create!(
      user: @user,
      step: "basic_info",
      wizard_data: {}
    )

    patch tournament_quick_path, params: {
      wizard: {
        name: "토요일 농구 대회",
        start_datetime: "2024-03-01T14:00",
        end_datetime: "2024-03-01T18:00",
        venue_name: "서울시민체육관",
        min_teams: 4,
        max_teams: 8,
        entry_fee: 20000
      },
      commit: "다음"
    }

    wizard.reload
    assert_equal "settings", wizard.step
    assert_equal "토요일 농구 대회", wizard.wizard_data["name"]
    assert_equal 8, wizard.wizard_data["max_teams"]
  end

  test "should move to previous step" do
    wizard = TournamentWizard.create!(
      user: @user,
      step: "settings",
      wizard_data: {}
    )

    patch previous_tournament_quick_path

    wizard.reload
    assert_equal "basic_info", wizard.step
  end

  test "should create tournament from wizard on final step" do
    wizard = TournamentWizard.create!(
      user: @user,
      step: "review",
      wizard_data: {
        "name" => "토요일 농구 대회",
        "description" => "즐거운 주말 농구",
        "start_datetime" => "2024-03-01T14:00",
        "end_datetime" => "2024-03-01T18:00",
        "venue_name" => "서울시민체육관",
        "venue_address" => "서울시 강남구",
        "min_teams" => 4,
        "max_teams" => 8,
        "entry_fee" => 20000,
        "game_type" => "5x5",
        "tournament_type" => "single_elimination",
        "generate_poster" => "true"
      }
    )

    assert_difference "Tournament.count", 1 do
      patch tournament_quick_path, params: {
        wizard: {},
        commit: "다음"
      }
    end

    tournament = Tournament.last
    assert_equal "토요일 농구 대회", tournament.name
    assert_equal @user, tournament.organizer
    assert tournament.is_quick_tournament
    assert tournament.auto_bracket_generation
    assert_equal "draft", tournament.status

    wizard.reload
    assert wizard.completed?
    assert_equal tournament, wizard.tournament
  end

  test "should show preview page" do
    tournament = create_quick_tournament

    get preview_tournament_quick_path(tournament)
    assert_response :success
  end

  test "should publish tournament" do
    tournament = create_quick_tournament

    assert_difference "TournamentShareLink.count", 3 do # kakao, instagram, general
      post publish_tournament_quick_path(tournament)
    end

    tournament.reload
    assert_equal "published", tournament.status
    assert_redirected_to tournament_path(tournament)
  end

  test "should show share page with links and qr code" do
    tournament = create_quick_tournament
    tournament.tournament_share_links.create!(
      share_type: "kakao",
      full_url: tournament_url(tournament)
    )

    get share_tournament_quick_path(tournament)
    assert_response :success
    assert_not_nil assigns(:share_links)
    assert_not_nil assigns(:qr_code)
  end

  private

  def log_in_as(user)
    post login_path, params: {
      session: {
        email: user.email,
        password: "password"
      }
    }
  end

  def create_quick_tournament
    Tournament.create!(
      name: "Test Tournament",
      organizer: @user,
      tournament_type: "single_elimination",
      game_type: "5x5",
      min_teams: 4,
      max_teams: 8,
      players_per_team: 5,
      entry_fee: 20000,
      tournament_start_at: 1.week.from_now,
      tournament_end_at: 1.week.from_now + 4.hours,
      registration_start_at: Time.current,
      registration_end_at: 6.days.from_now,
      venue_name: "Test Venue",
      is_quick_tournament: true,
      status: "draft"
    )
  end
end
