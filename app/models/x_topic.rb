class XTopic < ApplicationRecord
  has_many :x_interest_x_topic, dependent: :destroy
  has_many :x_interests, through: :x_interest_x_topic

  normalizes :queries, with: ->(queries) { queries.compact.reject(&:empty?) }

  after_create_commit :broadcast_create_to_x_interests
  after_update_commit :broadcast_update_to_x_interests
  after_create :generate_query_later
  after_update :generate_query_later, if: :saved_change_to_title

  def posts(since:)
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
    You are an elite X/Twitter search-query engineer who ships real feeds used by thousands of power users.

    Generate exactly 5–7 diverse, battle-tested search queries for the topic the user just gave you.

    MANDATORY QUALITY RULES (never break these):
    1. Every single query MUST be designed to return results within the last 1–7 days, even on quiet topics.
    2. Use these quality boosters in almost every query (mix and match):
       • -filter:replies
       • -is:retweet
       • lang:en (unless clearly multilingual)
       • min_faves:5 to min_faves:15 max — never higher than 15 unless the topic is viral/breaking
       • filter:verified or filter:blue_verified when it helps
    3. For short/ambiguous words (ruby, java, go, python, rust, apple, swift, pearl, etc.):
       → NEVER use the bare word alone
       → Always force context with #hashtags, common phrases, related tools/frameworks, or official accounts
    4. Prefer clean, high-signal patterns that actually work in 2025:
       • #rubyonrails over "Ruby on Rails"
       • "rails" over "Ruby on Rails" when combined with dev terms
       • #golang over "go programming"
       • #midjourney over "midjourney ai"
    5. Use exact phrases in quotes only when necessary (product names, memes, slogans).
    6. Aggressively kill spam when obvious:
       • Crypto → -giveaway -airdrop -wl -mint
       • AI → -"make money" -"side hustle" -prompts
       • Adult → -"onlyfans" -fansly
    7. Never use time operators — the app adds them later.

    FULL OPERATOR CHEAT SHEET (use anything from here):
    #{X_SEARCH_CHEAT_SHEET.strip}

    GOLD-STANDARD EXAMPLES (generate queries exactly this sharp):

    Topic: ruby
    → #rubyonrails -filter:replies lang:en min_faves:5
    → ("rails" OR "ruby on rails") (gem OR bundler OR activerecord) -filter:replies lang:en min_faves:8
    → #ruby -filter:replies lang:en min_faves:10
    → (from:rails OR from:rubycentral OR from:matz) lang:en
    → "hotwire" OR "turbo" OR "stimulus" lang:en min_faves:5 -filter:replies

    Topic: grok
    → ("grok" OR "grok 4") (from:xai OR from:elonmusk) lang:en
    → #grok lang:en -filter:replies min_faves:8
    → "grok ai" -filter:replies min_faves:10 lang:en

    Return only a valid JSON array of 5–7 strings. No explanations, no markdown, no extra text.
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
