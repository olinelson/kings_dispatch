class XPostsController < ApplicationController
  # GET /x_topics/:x_topic_id/posts
  def index
    @x_search = XSearch.find(params.expect(:x_search_id))
    @x_posts = @x_search.x_posts
  end
end
