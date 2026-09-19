# frozen_string_literal: true

require_relative 'front_matter'

module Jekyll
  module Md
    # Reads and merges site-wide and per-page configuration.
    class Configuration
      # Fields used when `frontmatter: true` is configured without an
      # explicit list.
      DEFAULT_FRONTMATTER_FIELDS = %w[title date tags].freeze

      DEFAULTS = {
        'enabled' => true,
        'selector' => nil,
        'strip' => %w[script style],
        'link' => true,
        'exclude' => [],
        'frontmatter' => false
      }.freeze

      def initialize(site_config)
        @config = DEFAULTS.merge(site_config || {})
      end

      def enabled?
        @config['enabled'] != false
      end

      def link?
        @config['link'] != false
      end

      def selector
        @config['selector']
      end

      def strip_selectors
        Array(@config['strip'])
      end

      def excluded?(url)
        Array(@config['exclude']).any? { |pattern| File.fnmatch(pattern, url, File::FNM_PATHNAME) }
      end

      # Per-page overrides via front matter:
      #   md: false            -- opt this page out entirely
      #   md_selector: "#main" -- override the CSS selector for this page
      #   md_link: false       -- don't inject the <link rel="alternate"> tag for this page
      def enabled_for?(item)
        return false unless enabled?

        item.data['md'] != false && !excluded?(item.url)
      end

      def link_for?(item)
        return false unless link?

        item.data['md_link'] != false && !excluded?(item.url)
      end

      def selector_for(item)
        item.data['md_selector'] || selector
      end

      # Resolves the list of front matter fields to build for +item+,
      # from (in order of precedence) per-page `md_frontmatter` front
      # matter, then the site-wide `frontmatter` config. Each may be:
      #   true          -- use DEFAULT_FRONTMATTER_FIELDS
      #   false / nil   -- disabled, returns []
      #   an array       -- an explicit list of field names
      def frontmatter_fields_for(item)
        normalize_frontmatter(item.data.key?('md_frontmatter') ? item.data['md_frontmatter'] : @config['frontmatter'])
      end

      private

      def normalize_frontmatter(value)
        case value
        when true
          DEFAULT_FRONTMATTER_FIELDS
        when Array
          value.map(&:to_s) & FrontMatter::FIELDS
        else
          []
        end
      end
    end
  end
end
