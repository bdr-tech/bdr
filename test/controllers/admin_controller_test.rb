require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get admin_dashboard_url
    assert_response :success
  end

  test "should get users" do
    get admin_users_url
    assert_response :success
  end

  test "should get games" do
    get admin_games_url
    assert_response :success
  end

  test "should get courts" do
    get admin_courts_url
    assert_response :success
  end
end
