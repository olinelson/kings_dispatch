
class GenerateQuerySchema < RubyLLM::Schema
  array of: :string, description: "The x query"
end

class XTopic < ApplicationRecord
  def generate_query
    chat = RubyLLM.chat.with_params(response_format: { type: "json_object" })
    response = chat.ask("")
  end

  private
end
