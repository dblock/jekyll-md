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
        'title_heading' => false
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

      def title_heading?
        @config['title_heading'] == true
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

      # Whether to prepend a "# Title" heading (from the page's front
      # matter `title`) to the converted Markdown body. Off by default
      # since the title is usually already inside the converted
      # selector/<main> region; useful when a layout renders the title
      # outside of it.
      #
      #   md: false                     -- site-wide default
      #   md_title_heading: true/false  -- per-page override
      def title_heading_for?(item)
        item.data['md_title_heading'].nil? ? title_heading? : item.data['md_title_heading'] != false
      end
    end
  end
end
