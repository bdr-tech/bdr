require "test_helper"

class CourtActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get check_in" do
    get court_activities_check_in_url
    assert_response :success
  end

  test "should get check_out" do
    get court_activities_check_out_url
    assert_response :success
  end

  test "should get report" do
    get court_activities_report_url
    assert_response :success
  end
end
