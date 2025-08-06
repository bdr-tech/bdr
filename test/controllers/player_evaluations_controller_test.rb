require "test_helper"

class PlayerEvaluationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get player_evaluations_new_url
    assert_response :success
  end

  test "should get create" do
    get player_evaluations_create_url
    assert_response :success
  end
end
