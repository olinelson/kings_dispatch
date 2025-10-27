RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.grok.api_key
  config.openai_api_base = "https://api.x.ai/v1"
  config.default_model = "grok-4"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
