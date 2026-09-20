# frozen_string_literal: true

require 'spec_helper'

describe 'building a site with jekyll-md' do
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    FileUtils.rm_rf(File.join(fixture_site_path, '_site'))
    @site = build_fixture_site
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    FileUtils.rm_rf(File.join(fixture_site_path, '_site'))
  end

  def site_file(path)
    File.read(File.join(fixture_site_path, '_site', path))
  end

  def site_file?(path)
    File.exist?(File.join(fixture_site_path, '_site', path))
  end

  it 'writes an index.md sibling for the homepage' do
    expect(site_file?('index.md')).to be(true)
    markdown = site_file('index.md')
    expect(markdown).to include('[world](https://example.com/world)')
    expect(markdown).to include('![A cat](https://example.com/cat.png)')
    expect(markdown).not_to include('Site navigation')
    expect(markdown).not_to include('Site footer')
  end

  it 'writes an about.md sibling for a page under a directory' do
    expect(site_file?('about.md')).to be(true)
    expect(site_file('about.md')).to include('This is the about page.')
  end

  it 'writes a markdown counterpart for a post' do
    expect(site_file?('2026/01/01/a-test-post.md')).to be(true)
    markdown = site_file('2026/01/01/a-test-post.md')
    expect(markdown).to include('[link](https://example.com)')
    expect(markdown).not_to include("alert('should be stripped')")
  end

  it 'does not write a markdown file for a page opted out via front matter' do
    expect(site_file?('opt-out.md')).to be(false)
  end

  it 'does not overwrite a hand-authored markdown sidecar' do
    expect(site_file('custom.md')).to eq("<p>Hand-authored content, do not overwrite.</p>\n")
  end

  it 'injects a markdown alternate link into the page head' do
    html = site_file('index.html')
    expect(html).to include('<link href="/index.md" type="text/markdown" rel="alternate" title="Markdown">')
  end

  it 'injects a markdown alternate link for a post' do
    html = site_file('2026/01/01/a-test-post.html')
    expect(html).to include(
      '<link href="/2026/01/01/a-test-post.md" type="text/markdown" rel="alternate" title="Markdown">'
    )
  end

  context 'with a per-page md_layout' do
    it 'wraps the converted content in the custom layout' do
      markdown = site_file('templated.md')
      expect(markdown).to eq(
        "# Templated Page\n\nThis page uses a custom per-page template.\n\n\n" \
        "Source: https://example.com/templated/\n"
      )
    end
  end

  context 'with a configured renderer' do
    let(:alt_destination) { File.join(fixture_site_path, '_site_kramdown') }

    before do
      Jekyll.logger.log_level = :error
      config = Jekyll.configuration(
        {
          'source' => fixture_site_path,
          'destination' => alt_destination,
          'md' => { 'renderer' => 'kramdown' }
        }
      )
      Jekyll::Site.new(config).process
    end

    after { FileUtils.rm_rf(alt_destination) }

    it 'uses the configured renderer instead of the default' do
      markdown = File.read(File.join(alt_destination, 'about.md'))
      expect(markdown).to include('This is the about page.')
      # kramdown's reference-style links are a visible marker that the
      # alternate renderer, not reverse_markdown, produced this file.
      post = File.read(File.join(alt_destination, '2026/01/01/a-test-post.md'))
      expect(post).to include('[link][1]')
    end
  end
end
