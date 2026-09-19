# frozen_string_literal: true

require 'yaml'

module Jekyll
  module Md
    # Builds an optional YAML front matter block for the generated
    # Markdown, from a page/document's own front matter and site
    # config, so an agent fetching the `.md` file gets structured
    # metadata without parsing the body.
    class FrontMatter
      # Fields the plugin knows how to derive; unknown field names in
      # config are ignored.
      FIELDS = %w[title date tags url author description].freeze

      # +fields+ is an array of field names (a subset of FIELDS, in the
      # order they should appear).
      def initialize(fields)
        @fields = fields
      end

      # Returns a YAML front matter block (including the leading and
      # trailing "---" lines and a blank line after) for +item+, or an
      # empty string if no configured field has a value.
      def build(item, site)
        return '' if @fields.empty?

        data = @fields.each_with_object({}) do |field, hash|
          value = value_for(field, item, site)
          next if value.nil? || (value.respond_to?(:empty?) && value.empty?)

          hash[field] = value
        end

        return '' if data.empty?

        "---\n#{YAML.dump(data).sub(/\A---\s*\n/, '')}---\n\n"
      end

      private

      def value_for(field, item, site)
        method_name = "#{field}_value"
        respond_to?(method_name, true) ? send(method_name, item, site) : nil
      end

      def title_value(item, _site)
        item.data['title']
      end

      def date_value(item, _site)
        format_date(item.data['date'])
      end

      def tags_value(item, _site)
        Array(item.data['tags']).map(&:to_s)
      end

      def url_value(item, site)
        "#{site.config['url']}#{site.config['baseurl']}#{item.url}"
      end

      def author_value(item, site)
        item.data['author'] || site.config['author']
      end

      def description_value(item, _site)
        item.data['description']
      end

      def format_date(date)
        return nil unless date

        date.respond_to?(:iso8601) ? date.iso8601 : date.to_s
      end
    end
  end
end
