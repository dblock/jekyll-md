# frozen_string_literal: true

require 'nokogiri'
require 'reverse_markdown'

module Jekyll
  module Md
    # Converts the final, fully-rendered HTML of a page into Markdown.
    #
    # Unlike plugins that render Markdown from the page's *source*
    # (with Liquid tags resolved but HTML left as-is), this converts the
    # actual rendered HTML output, so links, images and other inline
    # HTML end up as clean Markdown syntax instead of leaking through
    # verbatim, and any Liquid that only makes sense in the context of a
    # full page render (includes, site variables, conditionals) is
    # already fully resolved.
    class Converter
      def initialize(strip_selectors: [])
        @strip_selectors = strip_selectors
      end

      # Returns the converted Markdown for +html+, scoped to +selector+
      # (a CSS selector), or nil if the selector doesn't match anything.
      #
      # When +selector+ is nil, the entire page's <body> is converted.
      def convert(html, selector: nil)
        doc = Nokogiri::HTML(html)
        node = doc.at_css(selector || 'body')
        return nil unless node

        @strip_selectors.each { |s| node.css(s).remove }

        markdown = ReverseMarkdown.convert(
          node.inner_html,
          unknown_tags: :bypass,
          github_flavored: true
        ).strip

        return nil if markdown.empty?

        "#{markdown}\n"
      end

      # Derives the relative Markdown URL for a page's URL, e.g.:
      #   "/"               -> "/index.md"
      #   "/about/"         -> "/about.md"
      #   "/2026/foo.html"  -> "/2026/foo.md"
      #   "/tags/ruby/"     -> "/tags/ruby.md"
      def self.md_url_for(url)
        return '/index.md' if url.nil? || url.empty? || url == '/'

        if url.end_with?('/')
          "#{url.chomp('/')}.md"
        elsif url.end_with?('.html', '.htm')
          url.sub(/\.html?\z/, '.md')
        else
          "#{url}.md"
        end
      end
    end
  end
end
