# frozen_string_literal: true

require 'liquid'

module Jekyll
  module Md
    # Wraps the Markdown converted from a page/document's rendered HTML
    # in a Jekyll layout, so sites that want more than a flat body
    # (e.g. a title heading, a front matter block, a "Source:" link, or
    # any combination/order of these) can express it themselves
    # instead of the plugin growing a boolean per idea.
    #
    # Reuses Jekyll's own layout lookup (+site.layouts+, keyed by
    # basename without extension, read from `_layouts/`) rather than an
    # arbitrary file path -- the same place/mechanism as HTML layouts,
    # just rendered against the converted Markdown instead of HTML.
    # Give it a distinct name from any HTML layout (e.g.
    # `_layouts/md_page.liquid` instead of `_layouts/page.html`) so the
    # two don't collide in that lookup.
    class LayoutRenderer
      def initialize
        @cache = {}
      end

      # +layout_name+ is the name of a layout in `_layouts/` (without
      # extension). Exposes `content` (the already-converted Markdown),
      # `page` (the same front matter/data a Jekyll layout sees), and
      # `site` (the site payload) as Liquid variables.
      def render(layout_name, content, item, site)
        layout = site.layouts[layout_name]
        raise "jekyll-md: layout not found: #{layout_name}" unless layout

        parsed = @cache[layout_name] ||= Liquid::Template.parse(layout.content)
        parsed.render!(
          'content' => content,
          'page' => item.to_liquid,
          'site' => site.site_payload['site']
        )
      end
    end
  end
end
