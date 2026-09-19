# frozen_string_literal: true

require 'jekyll-md'
require 'jekyll'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

def fixture_site_path
  File.expand_path('fixtures/site', __dir__)
end

def build_fixture_site(config_overrides = {})
  Jekyll.logger.log_level = :error

  config = Jekyll.configuration(
    {
      'source' => fixture_site_path,
      'destination' => File.join(fixture_site_path, '_site')
    }.merge(config_overrides)
  )

  site = Jekyll::Site.new(config)
  site.process
  site
end
