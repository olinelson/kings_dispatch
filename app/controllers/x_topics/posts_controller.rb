class XTopics::PostsController < ApplicationController
  # GET /x_topics/:x_topic_id/posts
  def index
    @x_topic = XTopic.find(params[:x_topic_id])
    @posts = @x_topic.posts(since: DateTime.yesterday)
  end
end
