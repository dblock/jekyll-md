# frozen_string_literal: true

require 'kramdown'

module Jekyll
  module Md
    module Renderers
      # Renders HTML to Markdown (kramdown's own dialect, a superset of
      # Markdown) via kramdown, which already ships as a transitive
      # dependency of Jekyll itself -- no extra gem to install. See the
      # "Renderers" section of the README for its limitations compared
      # to reverse_markdown/html-to-markdown.
      class Kramdown
        def render(html)
          ::Kramdown::Document.new(html, input: 'html').to_kramdown
        end
      end
    end
  end
end
