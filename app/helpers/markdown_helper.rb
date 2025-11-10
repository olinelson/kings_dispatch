require "redcarpet"

module MarkdownHelper
  def markdown
    @markdown ||= Redcarpet::Markdown.new(renderer, extensions = {})
  end

  private

  def renderer
    Redcarpet::Render::HTML.new(render_options = {})
  end
end
