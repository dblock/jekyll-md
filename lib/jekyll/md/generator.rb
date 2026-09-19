# frozen_string_literal: true

require 'fileutils'
require 'jekyll'
require_relative 'configuration'
require_relative 'converter'

module Jekyll
  module Md
    # Runs after Jekyll has written the site: converts every eligible
    # page's rendered HTML output into a sibling Markdown file.
    Jekyll::Hooks.register :site, :post_write do |site|
      config = Configuration.new(site.config['md'])
      next unless config.enabled?

      converter = Converter.new(strip_selectors: config.strip_selectors)

      (site.pages + site.docs_to_write).each do |item|
        next unless item.destination(site.dest).end_with?('.html')
        next unless item.output.is_a?(String)
        next unless config.enabled_for?(item)

        md_url = Converter.md_url_for(item.url)
        dest_path = File.join(site.dest, md_url)

        # Don't clobber a page that Jekyll itself already wrote to this
        # path, e.g. a hand-authored /tags.md or /posts.md.
        next if File.exist?(dest_path)

        markdown = converter.convert(item.output, selector: config.selector_for(item))
        next unless markdown

        if config.source_link_for?(item)
          source_url = "#{site.config['url']}#{site.config['baseurl']}#{item.url}"
          markdown = "#{markdown}\nSource: #{source_url}\n"
        end

        FileUtils.mkdir_p(File.dirname(dest_path))
        File.write(dest_path, markdown)
      end
    end

    # Runs after each page/document is rendered (before layouts are
    # written to disk isn't quite right -- :post_render fires after the
    # full layout chain has been applied, so `item.output` is the final
    # HTML) and injects a <link rel="alternate" type="text/markdown">
    # tag pointing at the page's Markdown counterpart.
    Jekyll::Hooks.register %i[pages documents], :post_render do |item|
      config = Configuration.new(item.site.config['md'])
      next unless config.link_for?(item)
      next unless item.output.is_a?(String) && item.output.include?('</head>')

      md_url = Converter.md_url_for(item.url)
      link_tag = %(<link href="#{md_url}" type="text/markdown" rel="alternate" title="Markdown">\n)
      item.output = item.output.sub('</head>', "#{link_tag}</head>")
    end
  end
end
