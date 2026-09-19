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
      # When no selector is configured, try these, in order, before
      # falling back to the whole <body>. `<main>`/`[role="main"]` are
      # the closest thing to an HTML convention for "this is the page's
      # content, not its header/nav/footer chrome".
      DEFAULT_SELECTORS = ['main', '[role="main"]'].freeze

      def initialize(strip_selectors: [])
        @strip_selectors = strip_selectors
      end

      # Returns the converted Markdown for +html+, scoped to +selector+
      # (a CSS selector), or nil if the selector doesn't match anything.
      #
      # When +selector+ is nil, tries DEFAULT_SELECTORS in turn, falling
      # back to the entire page's <body> if none of them match.
      def convert(html, selector: nil)
        doc = Nokogiri::HTML(html)
        node = selector ? doc.at_css(selector) : default_node_for(doc)
        return nil unless node

        @strip_selectors.each { |s| node.css(s).remove }

        markdown = ReverseMarkdown.convert(
          node.inner_html,
          unknown_tags: :bypass,
          github_flavored: true
        ).strip

        # reverse_markdown renders non-breaking spaces (U+00A0) as the
        # literal HTML entity "&nbsp;" instead of a plain space, leaking
        # HTML into otherwise clean Markdown.
        markdown = markdown.gsub('&nbsp;', ' ')

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

      private

      def default_node_for(doc)
        DEFAULT_SELECTORS.each do |selector|
          node = doc.at_css(selector)
          return node if node
        end

        doc.at_css('body')
      end
    end
  end
end
