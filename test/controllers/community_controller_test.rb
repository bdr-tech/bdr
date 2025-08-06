require "test_helper"

class CommunityControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get community_index_url
    assert_response :success
  end

  test "should get posts" do
    get community_posts_url
    assert_response :success
  end

  test "should get events" do
    get community_events_url
    assert_response :success
  end

  test "should get reviews" do
    get community_reviews_url
    assert_response :success
  end
end
