# frozen_string_literal: true

module Jekyll
  module Md
    # Reads and merges site-wide and per-page configuration.
    class Configuration
      DEFAULTS = {
        'enabled' => true,
        'selector' => nil,
        'strip' => %w[script style],
        'link' => true,
        'exclude' => [],
        'layout' => nil
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

      def layout
        @config['layout']
      end

      # A per-page `md_layout` front matter value overrides the
      # site-wide layout; either may be `false` to opt a page back out
      # of the layout even when one is configured site-wide.
      def layout_for(item)
        return false if item.data['md_layout'] == false

        item.data['md_layout'] || layout
      end
    end
  end
end
