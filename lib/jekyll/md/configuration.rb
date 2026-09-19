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
        'source_link' => false
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

      def source_link?
        @config['source_link'] == true
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

      # Whether to append a "Source: <url>" line pointing back at the
      # canonical HTML page. Off by default; useful when a .md file may
      # be shared or fetched on its own, since there's otherwise no way
      # to get back to the live, styled page from it.
      #
      #   md: false                  -- site-wide default
      #   md_source_link: true/false -- per-page override
      def source_link_for?(item)
        return false if excluded?(item.url)

        item.data['md_source_link'].nil? ? source_link? : item.data['md_source_link'] != false
      end
    end
  end
end
