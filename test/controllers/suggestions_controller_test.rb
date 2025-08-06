require "test_helper"

class SuggestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get suggestions_create_url
    assert_response :success
  end
end
