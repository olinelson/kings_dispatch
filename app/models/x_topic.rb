class XTopic < ApplicationRecord
  has_many :x_interest_x_topic, dependent: :destroy
  has_many :x_interests, through: :x_interest_x_topic

  normalizes :queries, with: ->(queries) { queries.compact.reject(&:empty?) }

  after_create_commit :broadcast_create_to_x_interests
  after_update_commit :broadcast_update_to_x_interests
  after_create :generate_query_later
  after_update :generate_query_later, if: :saved_change_to_title

  def posts(since)
    formatted_queries = queries.map { "(#{it})" }.join(" OR ")
    X.search_posts(formatted_queries, since:)
  end

  def generate_query_later
    GenerateXTopicQueryJob.perform_later(self)
  end

  def generate_query
    chat = RubyLLM.chat
      .with_schema(GenerateQuerySchema)
      .with_instructions(instructions)
    response = chat.ask(title)
    queries = response.content["queries"]
    update! queries:
  end

  private

  def broadcast_create_to_x_interests
    x_interests.each do |x_interest|
      broadcast_append_later_to x_interest, partial: "x_topics/x_topic", locals: { x_topic: self }, target: "x_topics"
    end
  end

  def broadcast_update_to_x_interests
    x_interests.each do |x_interest|
      broadcast_replace_later_to x_interest, partial: "x_topics/x_topic", locals: { x_topic: self }
    end
  end

  def instructions
    <<~INSTRUCTIONS
      You are an expert X (formerly Twitter) search query constructor. Your task is to analyze a **topic title** and **description**, infer the user's intent, and generate a list of **highly effective X search queries** using the advanced operators below.

      ### Rules:
      - Generate **3–8 diverse, targeted queries** that cover different angles of the topic.
      - Use **advanced operators** from the cheat sheet to improve precision and recall.
      - Prioritize **specificity**, **relevance**, and **real-world search effectiveness**.
      - Combine operators logically (e.g. `from:`, `filter:`, `since:`, `min_faves:`, etc.).
      - Avoid generic or overly broad queries unless justified.
      - Don't include any time related queries - this is managed separately
      - If the topic involves media, use `filter:media`, `filter:twimg`, etc.
      - If the topic involves people/orgs, use `from:`, `to:`, or `@`.

      ### Operator Cheat Sheet:
      #{X_SEARCH_CHEAT_SHEET.strip}

      Now, generate queries for the given topic.
      INSTRUCTIONS
  end

  class GenerateQuerySchema < RubyLLM::Schema
    array :queries, of: :string, description: "An array of X queries that match the examples from the documentation. Each item in an array must be a complete query expression."
  end

  X_SEARCH_CHEAT_SHEET = <<~Markdown
  ## Tweet Content
  - `nasa esa` `(nasa esa)` — Both `nasa` and `esa`. Spaces = AND. Use parentheses to group.
  - `nasa OR esa` — Either `nasa` or `esa`. `OR` uppercase.
  - `"state of the art"` — Exact phrase. Matches `state-of-the-art`. Quotes block spell correction.
  - `"this is the * time this week"` — Phrase with wildcard. `*` only in quotes with spaces.
  - `+radiooooo` — Force exact term (no spell correction).
  - `-love` `-"live laugh love"` — Exclude word or phrase. Works with quotes and operators.
  - `#tgif` — Hashtag
  - `$TWTR` — Cashtag (stock symbols)
  - `What ?` — Question mark matched
  - `:)` `:-)` `:P` `:D` `:-(` `:(` — Positive or negative emoticons
  - `eye` — Emoji (needs another operator)
  - `url:google.com` — URLs by domain/subdomain. Use `_` for hyphens: `url:t_mobile.com`
  - `lang:en` — Language filter. Not 100% accurate.

  ## Users
  - `from:user` — Sent by `@user`
  - `to:user` — Replying to `@user`
  - `@user` — Mentioning `@user`. Use `-from:user` to exclude self-mentions.
  - `list:ID` `list:user/listname` — From public list
  - `filter:verified` — Verified accounts
  - `filter:blue_verified` — Paid verified (X Premium)
  - `filter:follows` — From accounts you follow
  - `filter:social` `filter:trusted` — Your expanded network (Top tab only)

  ## Geo
  - `near:city` `near:"The Hague"` — Geotagged near location
  - `near:me` — Near your location
  - `within:10km` — Radius of `near:` (km or mi)
  - `geocode:lat,long,radius` — Precise circle
  - `place:96683cc9126741d1` — By Place ID (e.g. USA)

  ## Time
  - `since:2021-12-31` — On or after date
  - `until:2021-12-31` — Before date
  - `since:2021-12-31_23:59:59_UTC` — With time + timezone
  - `since_time:1142974200` — Unix timestamp
  - `within_time:2d` `3h` `5m` `30s` — Last X days/hours/minutes/seconds
  - `since_id:tweet_id` — After Snowflake ID
  - `max_id:tweet_id` — At or before Snowflake ID

  ## Tweet Type
  - `filter:nativeretweets` — Official retweets (~7–10 days)
  - `include:nativeretweets` — Include native retweets
  - `filter:retweets` — Old RTs + quotes
  - `filter:replies` — Any replies
  - `filter:self_threads` — Self-replies (threads)
  - `conversation_id:tweet_id` — All in thread
  - `filter:quote` — Quote tweets
  - `quoted_tweet_id:tweet_id` — Quotes of specific tweet
  - `quoted_user_id:user_id` — Quotes of user by ID
  - `card_name:poll*` — Polls (2–4 choices, text/image)

  ## Engagement
  - `filter:has_engagement` — Any engagement
  - `min_retweets:5` — At least X retweets
  - `min_faves:10` — At least X likes
  - `min_replies:100` — At least X replies
  - `-min_retweets:500` — Max X retweets

  ## Media
  - `filter:media` — Any media
  - `filter:twimg` — Native images (`pic.twitter.com`)
  - `filter:images` — All images
  - `filter:videos` — All videos
  - `filter:native_video` — Twitter video (incl. Vine, Periscope)
  - `filter:spaces` — Twitter Spaces

  ## More Filters
  - `filter:links` — Any URL (`-filter:media` for non-media)
  - `filter:mentions` — @mentions
  - `filter:news` — News domain links
  - `filter:safe` — Exclude sensitive content
  - `filter:hashtags` — Hashtags

  ## App & Card Specific
  - `source:"TweetDeck"` — From specific app
  - `card_name:audio` — Audio cards
  - `card_name:animated_gif` — GIFs
  - `card_name:summary_large_image` — Large image cards
  Markdown
end
