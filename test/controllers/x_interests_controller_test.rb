require "test_helper"

class XInterestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @x_interest = x_interests(:one)
  end

  test "should get index" do
    get x_interests_url
    assert_response :success
  end

  test "should get new" do
    get new_x_interest_url
    assert_response :success
  end

  test "should create x_interest" do
    assert_difference("XInterest.count") do
      post x_interests_url, params: { x_interest: { user_id: @x_interest.user_id } }
    end

    assert_redirected_to x_interest_url(XInterest.last)
  end

  test "should show x_interest" do
    get x_interest_url(@x_interest)
    assert_response :success
  end

  test "should get edit" do
    get edit_x_interest_url(@x_interest)
    assert_response :success
  end

  test "should update x_interest" do
    patch x_interest_url(@x_interest), params: { x_interest: { user_id: @x_interest.user_id } }
    assert_redirected_to x_interest_url(@x_interest)
  end

  test "should destroy x_interest" do
    assert_difference("XInterest.count", -1) do
      delete x_interest_url(@x_interest)
    end

    assert_redirected_to x_interests_url
  end
end
