# frozen_string_literal: true

require_relative 'renderers/reverse_markdown_renderer'
require_relative 'renderers/html_to_markdown_renderer'
require_relative 'renderers/kramdown_renderer'

module Jekyll
  module Md
    # Looks up a Markdown renderer by its configured name (`md:
    # renderer:`).
    module Renderer
      RENDERERS = {
        'reverse_markdown' => Renderers::ReverseMarkdown,
        'html-to-markdown' => Renderers::HtmlToMarkdown,
        'kramdown' => Renderers::Kramdown
      }.freeze

      def self.for(name)
        klass = RENDERERS[name]
        raise "jekyll-md: unknown renderer #{name.inspect}, expected one of #{RENDERERS.keys.join(', ')}" unless klass

        klass.new
      end
    end
  end
end
