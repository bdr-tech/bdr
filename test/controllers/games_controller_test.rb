require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      name: "Test User",
      phone: "010-1234-5678",
      nickname: "testuser",
      real_name: "테스트 유저",
      height: 180,
      weight: 75,
      positions: [ "PG" ],
      city: "서울특별시",
      district: "강남구"
    )

    @game = Game.create!(
      organizer: @user,
      game_id: "BDR-20250720-PKG-001",
      game_type: "픽업게임",
      title: "테스트 게임",
      city: "서울특별시",
      district: "강남구",
      venue_name: "테스트 체육관",
      venue_address: "테스트 주소",
      scheduled_at: 1.day.from_now,
      start_time: "14:00",
      end_time: "16:00",
      max_players: 10,
      level: 3,
      fee: 10000
    )

    # 세션에 사용자 ID 설정 (로그인 상태 시뮬레이션)
    post login_path, params: { phone: @user.phone }
  end

  test "should get index" do
    get games_path
    assert_response :success
    assert_select "h1", "🏀 경기 목록"
  end

  test "should filter games by city" do
    get games_path, params: { city: "서울특별시" }
    assert_response :success
  end

  test "should get today games" do
    get today_games_path
    assert_response :success
    assert_select "h1", "⚡ 3초룰 경기"
  end

  test "should get new when logged in" do
    get new_game_path
    assert_response :success
    assert_select "h1", "🏀 새 경기 만들기"
  end

  test "should redirect to login when not logged in for new" do
    delete logout_path
    get new_game_path
    assert_redirected_to login_path
  end

  test "should create game when valid" do
    assert_difference("Game.count") do
      post games_path, params: {
        game: {
          game_type: "픽업게임",
          team_name: "새로운 팀",
          city: "서울특별시",
          district: "강남구",
          title: "새 게임",
          venue_name: "체육관",
          venue_address: "주소",
          scheduled_at: 2.days.from_now,
          start_time: "15:00",
          end_time: "17:00",
          max_players: 12,
          level: 3,
          fee: 5000
        }
      }
    end

    assert_redirected_to Game.last
    follow_redirect!
    assert_match "경기가 성공적으로 생성되었습니다", flash[:notice]
  end

  test "should show game" do
    get game_path(@game)
    assert_response :success
    assert_select "h1", @game.title
  end

  test "should show quick match page" do
    get quick_match_path
    assert_response :success
    assert_match "빠른 매칭", response.body
  end

  test "should apply for game when logged in" do
    post apply_game_path(@game), params: { message: "참가하고 싶습니다" }
    assert_redirected_to @game
    follow_redirect!
    assert_match "경기 참가 신청이 완료되었습니다", flash[:notice]
  end

  test "should not apply twice for same game" do
    GameApplication.create!(user: @user, game: @game, status: "pending")

    post apply_game_path(@game)
    assert_redirected_to @game
    follow_redirect!
    assert_match "이미 신청한 경기입니다", flash[:alert]
  end

  test "organizer should approve application" do
    other_user = User.create!(
      name: "Other User",
      phone: "010-9999-8888",
      nickname: "other"
    )
    application = GameApplication.create!(
      user: other_user,
      game: @game,
      status: "pending"
    )

    post approve_application_game_path(@game, application_id: application.id)
    assert_redirected_to @game

    application.reload
    assert_equal "approved", application.status
  end

  test "non-organizer should not approve application" do
    other_user = User.create!(
      name: "Other User",
      phone: "010-9999-8888",
      nickname: "other"
    )
    other_game = Game.create!(
      organizer: other_user,
      game_id: "BDR-20250720-PKG-002",
      title: "다른 게임",
      scheduled_at: 1.day.from_now
    )

    application = GameApplication.create!(
      user: @user,
      game: other_game,
      status: "pending"
    )

    post approve_application_game_path(other_game, application_id: application.id)
    assert_redirected_to other_game
    follow_redirect!
    assert_match "권한이 없습니다", flash[:alert]
  end

  test "should handle missing game gracefully" do
    get game_path("nonexistent")
    assert_redirected_to games_path
    follow_redirect!
    assert_match "경기를 찾을 수 없습니다", flash[:alert]
  end
end
