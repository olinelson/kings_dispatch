require "test_helper"

class XSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @x_search = x_searches(:one)
  end

  test "should get index" do
    get x_searches_url
    assert_response :success
  end

  test "should get new" do
    get new_x_search_url
    assert_response :success
  end

  test "should create x_search" do
    assert_difference("XSearch.count") do
      post x_searches_url, params: { x_search: { end_time: @x_search.end_time, start_time: @x_search.start_time, x_topic_id: @x_search.x_topic_id } }
    end

    assert_redirected_to x_search_url(XSearch.last)
  end

  test "should show x_search" do
    get x_search_url(@x_search)
    assert_response :success
  end

  test "should get edit" do
    get edit_x_search_url(@x_search)
    assert_response :success
  end

  test "should update x_search" do
    patch x_search_url(@x_search), params: { x_search: { end_time: @x_search.end_time, start_time: @x_search.start_time, x_topic_id: @x_search.x_topic_id } }
    assert_redirected_to x_search_url(@x_search)
  end

  test "should destroy x_search" do
    assert_difference("XSearch.count", -1) do
      delete x_search_url(@x_search)
    end

    assert_redirected_to x_searches_url
  end
end
