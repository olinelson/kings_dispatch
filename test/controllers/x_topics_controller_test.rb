require "test_helper"

class XTopicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @x_topic = x_topics(:one)
  end

  test "should get index" do
    get x_topics_url
    assert_response :success
  end

  test "should get new" do
    get new_x_topic_url
    assert_response :success
  end

  test "should create x_topic" do
    assert_difference("XTopic.count") do
      post x_topics_url, params: { x_topic: { description: @x_topic.description, query: @x_topic.query, title: @x_topic.title } }
    end

    assert_redirected_to x_topic_url(XTopic.last)
  end

  test "should show x_topic" do
    get x_topic_url(@x_topic)
    assert_response :success
  end

  test "should get edit" do
    get edit_x_topic_url(@x_topic)
    assert_response :success
  end

  test "should update x_topic" do
    patch x_topic_url(@x_topic), params: { x_topic: { description: @x_topic.description, query: @x_topic.query, title: @x_topic.title } }
    assert_redirected_to x_topic_url(@x_topic)
  end

  test "should destroy x_topic" do
    assert_difference("XTopic.count", -1) do
      delete x_topic_url(@x_topic)
    end

    assert_redirected_to x_topics_url
  end
end
