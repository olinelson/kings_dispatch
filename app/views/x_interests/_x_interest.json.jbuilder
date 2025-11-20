json.extract! x_interest, :id, :description, :user_id, :created_at, :updated_at
json.url x_interest_url(x_interest, format: :json)
json.description x_interest.description.to_s
