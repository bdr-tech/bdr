require "test_helper"

class TournamentCheckInTest < ActiveSupport::TestCase
  def setup
    @tournament = tournaments(:one)
    @user = users(:one)
    @team = tournament_teams(:one)
    @check_in = TournamentCheckIn.create!(
      tournament: @tournament,
      user: @user,
      tournament_team: @team,
      role: "player"
    )
  end

  test "should validate role inclusion" do
    assert_includes TournamentCheckIn::ROLES, @check_in.role

    assert_raises(ActiveRecord::RecordInvalid) do
      @check_in.update!(role: "invalid_role")
    end
  end

  test "should generate qr code on creation" do
    assert_not_nil @check_in.qr_code
    assert_equal 32, @check_in.qr_code.length # hex(16) = 32 chars
  end

  test "should have unique qr code" do
    another_check_in = TournamentCheckIn.create!(
      tournament: @tournament,
      user: users(:two),
      role: "player"
    )

    assert_not_equal @check_in.qr_code, another_check_in.qr_code
  end

  test "should check in with timestamp and device info" do
    assert_nil @check_in.checked_in_at
    assert_not @check_in.checked_in?

    device_info = "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)"
    @check_in.check_in!(device_info)

    assert_not_nil @check_in.checked_in_at
    assert_equal device_info, @check_in.device_info
    assert @check_in.checked_in?
  end

  test "should scope by check in status" do
    checked_in = TournamentCheckIn.create!(
      tournament: @tournament,
      user: users(:two),
      role: "player",
      checked_in_at: Time.current
    )

    pending = TournamentCheckIn.create!(
      tournament: @tournament,
      user: users(:three),
      role: "player"
    )

    assert_includes TournamentCheckIn.checked_in, checked_in
    assert_not_includes TournamentCheckIn.checked_in, pending

    assert_includes TournamentCheckIn.pending, pending
    assert_not_includes TournamentCheckIn.pending, checked_in
  end

  test "should scope by role" do
    player = @check_in
    coach = TournamentCheckIn.create!(
      tournament: @tournament,
      user: users(:two),
      role: "coach"
    )

    assert_includes TournamentCheckIn.players, player
    assert_not_includes TournamentCheckIn.players, coach
  end

  test "should order by recent check in" do
    old_check_in = TournamentCheckIn.create!(
      tournament: @tournament,
      user: users(:two),
      role: "player",
      checked_in_at: 1.hour.ago
    )

    new_check_in = TournamentCheckIn.create!(
      tournament: @tournament,
      user: users(:three),
      role: "player",
      checked_in_at: 1.minute.ago
    )

    recent = TournamentCheckIn.recent
    assert_equal new_check_in, recent.first
    assert_equal old_check_in, recent.second
  end
end
