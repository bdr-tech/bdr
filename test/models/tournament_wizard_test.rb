require "test_helper"

class TournamentWizardTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @wizard = TournamentWizard.create!(
      user: @user,
      step: "template_selection",
      wizard_data: {}
    )
  end

  test "should have valid steps" do
    assert_equal %w[template_selection basic_info settings review], TournamentWizard::STEPS
  end

  test "should start at template_selection step" do
    assert_equal "template_selection", @wizard.step
  end

  test "should calculate current step index" do
    assert_equal 0, @wizard.current_step_index

    @wizard.update!(step: "basic_info")
    assert_equal 1, @wizard.current_step_index

    @wizard.update!(step: "review")
    assert_equal 3, @wizard.current_step_index
  end

  test "should move to next step" do
    assert_equal "template_selection", @wizard.step

    @wizard.next_step!
    assert_equal "basic_info", @wizard.step

    @wizard.next_step!
    assert_equal "settings", @wizard.step

    @wizard.next_step!
    assert_equal "review", @wizard.step

    @wizard.next_step!
    assert @wizard.completed?
  end

  test "should move to previous step" do
    @wizard.update!(step: "review")

    @wizard.previous_step!
    assert_equal "settings", @wizard.step

    @wizard.previous_step!
    assert_equal "basic_info", @wizard.step

    @wizard.previous_step!
    assert_equal "template_selection", @wizard.step

    # Should not go before first step
    @wizard.previous_step!
    assert_equal "template_selection", @wizard.step
  end

  test "should calculate progress percentage" do
    assert_equal 25, @wizard.progress_percentage

    @wizard.update!(step: "basic_info")
    assert_equal 50, @wizard.progress_percentage

    @wizard.update!(step: "settings")
    assert_equal 75, @wizard.progress_percentage

    @wizard.update!(step: "review")
    assert_equal 100, @wizard.progress_percentage
  end

  test "should store wizard data as JSON" do
    data = {
      "name" => "토요일 농구 대회",
      "max_teams" => 8,
      "entry_fee" => 20000
    }

    @wizard.update!(wizard_data: data)
    @wizard.reload

    assert_equal "토요일 농구 대회", @wizard.wizard_data["name"]
    assert_equal 8, @wizard.wizard_data["max_teams"]
    assert_equal 20000, @wizard.wizard_data["entry_fee"]
  end

  test "should belong to user" do
    assert_equal @user, @wizard.user
  end

  test "should optionally belong to tournament" do
    assert_nil @wizard.tournament

    tournament = tournaments(:one)
    @wizard.update!(tournament: tournament)
    assert_equal tournament, @wizard.tournament
  end

  test "should validate step inclusion" do
    assert_raises(ActiveRecord::RecordInvalid) do
      @wizard.update!(step: "invalid_step")
    end
  end
end
