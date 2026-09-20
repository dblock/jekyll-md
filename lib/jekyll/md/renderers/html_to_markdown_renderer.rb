# frozen_string_literal: true

module Jekyll
  module Md
    module Renderers
      # Renders HTML to Markdown via the html-to-markdown gem, a
      # Rust-backed converter that produces output nearly identical to
      # reverse_markdown (only styling italics as `*x*` instead of
      # `_x_`) but significantly faster.
      #
      # Not a dependency of jekyll-md -- add
      #   gem "html-to-markdown"
      # to your own Gemfile to use `md: renderer: html-to-markdown`.
      class HtmlToMarkdown
        def initialize
          require 'html_to_markdown'
        rescue LoadError
          raise LoadError,
                'jekyll-md: the html-to-markdown renderer requires the html-to-markdown gem; ' \
                'add `gem "html-to-markdown"` to your Gemfile'
        end

        def render(html)
          ::HtmlToMarkdown.convert(html).to_s
        end
      end
    end
  end
end
