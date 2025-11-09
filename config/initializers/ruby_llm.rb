RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.openai.api_key
  # config.openai_api_base = "https://api.x.ai/v1"
  config.default_model = "openai"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
