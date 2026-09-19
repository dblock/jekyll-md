# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'jekyll/md/version'

Gem::Specification.new do |s|
  s.name = 'jekyll-md'
  s.version = Jekyll::Md::VERSION
  s.authors = ['Daniel Doubrovkine']
  s.email = 'dblock@dblock.org'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 3.0'
  s.required_rubygems_version = '>= 2.5'
  s.files = Dir['lib/**/*'] + ['README.md', 'LICENSE.md', 'CHANGELOG.md']
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/dblock/jekyll-md'
  s.licenses = ['MIT']
  s.summary = 'Serves a clean Markdown version of every page, converted from the rendered HTML.'
  s.description = <<-DESC
    A Jekyll plugin that converts each page's fully rendered HTML output into a Markdown
    sibling file (e.g. /about/index.html -> /about.md) and adds a discovery
    <link rel="alternate" type="text/markdown"> tag to every page's <head>.
  DESC
  s.add_dependency 'jekyll', '>= 4.4'
  s.add_dependency 'nokogiri'
  s.add_dependency 'reverse_markdown', '>= 2.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
