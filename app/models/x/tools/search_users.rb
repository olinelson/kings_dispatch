class X::Tools::SearchUsers < RubyLLM::Tool
  description "Searches for X (Twitter) users by keyword"

  params do  # the params DSL is only available in v1.9+. older versions should use the param helper instead
    string :query, description: "The search query, usually a persons name (eg. Donald Trump)"
    string :cursor, description: "The pagination cursor (optional)"
  end

  def execute(query:, cursor: nil)
    X.users_by_keyword(query, cursor)
  rescue => e
    { error: e.message }
  end
end
