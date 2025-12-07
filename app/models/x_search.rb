class XSearch < ApplicationRecord
  belongs_to :x_topic
  has_many :x_posts

  def search_posts(since:)
    data = X.search_posts(x_topic.formatted_queries, since:)
    tweets = data["tweets"]
    tweets.each do |t|
      x_posts.create!(external_id: t["id"], data: t)
    end
  end
end
