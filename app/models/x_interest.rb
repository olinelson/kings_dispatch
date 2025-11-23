class XInterest < ApplicationRecord
  has_many :x_interest_x_topic, dependent: :destroy
  has_many :x_topics, through: :x_interest_x_topic

  after_create_commit :generate_topics
  after_update_commit :generate_topics

  belongs_to :user
  has_rich_text :description

  def instructions
    <<~INSTRUCTIONS
      You are an expert X (formerly Twitter) topic extractor.

      Given a user's natural-language description of their interests on X, extract a precise list of topics or keywords that best represent what they want to see in their feed.

      Rules:
      - Return ONLY a flat array of strings. No explanations, no extra text.
      - Each string must be 1–6 words max.
      - Be specific (e.g. "Grok 4 updates" > "AI").
      - Do not add topics the user did not express or strongly imply.
      INSTRUCTIONS
  end

  def generate_topics
    chat = RubyLLM.chat.with_schema(GenerateTopicsSchema).with_instructions(instructions)
    response = chat.ask(description.body.to_s)
    topics = response.content["topics"]
    topics.each do |topic|
      x_topic = XTopic.find_or_create_by(title: topic)
      x_topics << x_topic
    end
  end

  private

  class GenerateTopicsSchema < RubyLLM::Schema
    array :topics, of: :string, description: "X topics"
  end
end
