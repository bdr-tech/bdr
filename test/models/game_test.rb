require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @organizer = User.create!(
      name: "Organizer",
      phone: "010-1111-2222",
      nickname: "organizer",
      real_name: "주최자",
      height: 180,
      weight: 80,
      positions: [ "C" ],
      city: "서울특별시",
      district: "강남구",
      birth_date: "1990-01-01",
      basketball_experience: 10
    )

    @game = Game.new(
      organizer: @organizer,
      game_type: "픽업게임",
      team_name: "테스트팀",
      city: "서울특별시",
      district: "강남구",
      title: "주말 농구 게임",
      venue_name: "강남체육관",
      venue_address: "강남구 테헤란로 123",
      scheduled_at: 2.days.from_now,
      start_time: "14:00",
      end_time: "16:00",
      max_players: 10,
      level: 3,
      fee: 10000
    )
  end

  test "should be valid" do
    assert @game.valid?
  end

  test "should require organizer" do
    @game.organizer = nil
    assert_not @game.valid?
  end

  test "should generate game_id before create" do
    assert_nil @game.game_id
    @game.save
    assert_not_nil @game.game_id
    assert_match /^BDR-\d{8}-PKG-\d{3}$/, @game.game_id
  end

  test "game_id should include correct game type code" do
    @game.game_type = "게스트모집"
    @game.save
    assert_match /^BDR-\d{8}-GST-\d{3}$/, @game.game_id

    @game.game_type = "TvT연습경기"
    @game.game_id = nil
    @game.save
    assert_match /^BDR-\d{8}-TVT-\d{3}$/, @game.game_id
  end

  test "should calculate revenue correctly" do
    @game.save

    # 참가비 10,000원, 플랫폼 수수료 5%
    assert_equal 10000, @game.fee
    assert_equal 5.0, @game.current_platform_fee_percentage

    # 예상 수익 계산
    assert_equal 100000, @game.expected_total_revenue # 10명 * 10,000원
    assert_equal 5000, @game.expected_platform_fee    # 100,000원 * 5%
    assert_equal 95000, @game.expected_host_revenue   # 100,000원 - 5,000원
  end

  test "should validate max_players" do
    @game.max_players = 0
    assert_not @game.valid?

    @game.max_players = -1
    assert_not @game.valid?

    @game.max_players = 30
    assert @game.valid?
  end

  test "should validate fee" do
    @game.fee = -1000
    assert_not @game.valid?

    @game.fee = 0
    assert @game.valid? # 무료 게임 가능
  end

  test "confirmed players count" do
    @game.save
    assert_equal 0, @game.confirmed_players_count

    # 참가자 추가 시뮬레이션
    player = User.create!(
      name: "Player",
      phone: "010-3333-4444",
      nickname: "player1"
    )

    application = @game.game_applications.create!(
      user: player,
      status: "final_approved"
    )

    assert_equal 1, @game.confirmed_players_count
  end

  test "can accept players" do
    @game.max_players = 2
    @game.save

    assert @game.can_accept_players?

    # 2명의 참가자 추가
    2.times do |i|
      player = User.create!(
        name: "Player#{i}",
        phone: "010-5555-#{6666 + i}",
        nickname: "player#{i}"
      )
      @game.game_applications.create!(
        user: player,
        status: "final_approved"
      )
    end

    assert_not @game.can_accept_players?
  end

  test "uniform colors serialization" do
    @game.uniform_colors = [ "white", "black" ]
    @game.save

    @game.reload
    assert_equal [ "white", "black" ], @game.uniform_colors
    assert_includes @game.uniform_colors_names, "흰색"
    assert_includes @game.uniform_colors_names, "검은색"
  end

  test "scopes" do
    # 과거 게임
    past_game = @game.dup
    past_game.scheduled_at = 1.day.ago
    past_game.save

    # 미래 게임
    @game.save

    assert_includes Game.upcoming, @game
    assert_not_includes Game.upcoming, past_game

    # 오늘 게임
    today_game = @game.dup
    today_game.scheduled_at = Time.current
    today_game.save

    assert_includes Game.today, today_game
  end

  test "fee display" do
    @game.fee = 0
    assert_equal "무료", @game.fee_display

    @game.fee = 10000
    assert_equal "10,000원", @game.fee_display
  end

  test "level name" do
    @game.level = 1
    assert_equal "루키", @game.level_name

    @game.level = 5
    assert_equal "프로", @game.level_name
  end
end
