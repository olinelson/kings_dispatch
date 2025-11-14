class X
  class << self
    def conn
      @conn ||= Faraday.new("https://api.twitterapi.io/", headers: { 'X-API-Key': api_key }) do |builder|
        builder.request :json
        builder.response :raise_error, include_request: true
        builder.response :json
        builder.response :logger, Rails.logger, bodies: true
      end
    end
    # Step 3: Use Bearer Token to make API request
    def user_info(user_name)
      res = conn.get("/twitter/user/info") do |req|
        req.params["userName"] = user_name
      end
      res.body
    end

    def search_posts(query)
      res = conn.get("/twitter/tweet/advanced_search") do |req|
        req.params["query"] = query
      end
      res.body
    end

    private

    def api_key
      Rails.application.credentials.twitter_api_key
    end
  end
end
