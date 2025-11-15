json.extract! x_topic, :id, :title, :description, :query, :created_at, :updated_at
json.url x_topic_url(x_topic, format: :json)
