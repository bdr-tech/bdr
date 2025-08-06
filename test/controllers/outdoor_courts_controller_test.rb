require "test_helper"

class OutdoorCourtsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get outdoor_courts_index_url
    assert_response :success
  end

  test "should get show" do
    get outdoor_courts_show_url
    assert_response :success
  end

  test "should get new" do
    get outdoor_courts_new_url
    assert_response :success
  end

  test "should get create" do
    get outdoor_courts_create_url
    assert_response :success
  end

  test "should get edit" do
    get outdoor_courts_edit_url
    assert_response :success
  end

  test "should get update" do
    get outdoor_courts_update_url
    assert_response :success
  end

  test "should get destroy" do
    get outdoor_courts_destroy_url
    assert_response :success
  end
end
