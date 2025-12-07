class XSearch < ApplicationRecord
  belongs_to :x_topic
  has_many :x_posts

  after_create_commit :search_posts

  def search_posts
    posts = X.search_posts(formatted_queries, since: start_time)
  end
end
