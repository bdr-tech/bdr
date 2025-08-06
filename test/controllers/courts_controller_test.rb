require "test_helper"

class CourtsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get courts_index_url
    assert_response :success
  end

  test "should get show" do
    get courts_show_url
    assert_response :success
  end
end
