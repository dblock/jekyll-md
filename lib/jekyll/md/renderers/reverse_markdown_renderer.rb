# frozen_string_literal: true

require 'reverse_markdown'

module Jekyll
  module Md
    module Renderers
      # Renders HTML to Markdown via the reverse_markdown gem (the
      # default) -- a pure-Ruby, GitHub-flavored converter. A hard
      # dependency of jekyll-md, so this renderer is always available.
      class ReverseMarkdown
        def render(html)
          ::ReverseMarkdown.convert(html, unknown_tags: :bypass, github_flavored: true)
        end
      end
    end
  end
end
