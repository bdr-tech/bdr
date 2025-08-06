require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: "Test User",
      email: "test@example.com",
      phone: "010-1234-5678",
      nickname: "testuser",
      real_name: "테스트 유저",
      height: 180,
      weight: 75,
      positions: [ "PG", "SG" ],
      city: "서울특별시",
      district: "강남구",
      birth_date: "1990-01-01",
      basketball_experience: 5
    )
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "nickname should be present" do
    @user.nickname = "   "
    assert_not @user.valid?
  end

  test "nickname should be unique" do
    duplicate_user = @user.dup
    duplicate_user.nickname = @user.nickname.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "phone should be unique" do
    duplicate_user = @user.dup
    duplicate_user.nickname = "different"
    @user.save
    assert_not duplicate_user.valid?
  end

  test "profile completion should be calculated correctly" do
    incomplete_user = User.new(name: "Incomplete")
    assert incomplete_user.profile_completion_percentage < 100

    complete_user = User.new(
      nickname: "complete",
      real_name: "완성된 유저",
      phone: "010-9999-8888",
      height: 175,
      weight: 70,
      positions: [ "C" ],
      city: "서울특별시",
      district: "강남구",
      birth_date: "1995-01-01",
      basketball_experience: 3
    )
    assert_equal 100, complete_user.profile_completion_percentage
  end

  test "can participate in games when profile is complete" do
    assert @user.can_participate_in_games?

    @user.nickname = nil
    assert_not @user.can_participate_in_games?
  end

  test "should track cancellation limits" do
    @user.save

    # 24시간 내 3회 취소 제한
    assert @user.can_apply_for_games?

    @user.cancellation_count_last_24h = 3
    assert_not @user.can_apply_for_games?

    # 1주일 내 5회 취소 제한
    @user.cancellation_count_last_24h = 2
    @user.cancellation_count_last_week = 5
    assert_not @user.can_apply_for_games?
  end

  test "should have many organized games" do
    @user.save
    game = Game.new(
      organizer: @user,
      game_id: "BDR-20250720-PKG-001",
      title: "Test Game",
      scheduled_at: 1.day.from_now
    )
    assert_includes @user.organized_games, game
  end

  test "admin status" do
    assert_not @user.admin?

    @user.admin = true
    assert @user.admin?
  end

  test "display name priority" do
    @user.nickname = "testnick"
    @user.name = "Test Name"
    assert_equal "testnick", @user.display_name

    @user.nickname = nil
    assert_equal "Test Name", @user.display_name
  end
end
