# frozen_string_literal: true

require 'spec_helper'

describe Jekyll::Md::Converter do
  subject(:converter) { described_class.new(strip_selectors: %w[script]) }

  describe '#convert' do
    it 'converts a link to markdown syntax' do
      html = '<body><div id="content"><a href="https://example.com">hi</a></div></body>'
      expect(converter.convert(html, selector: '#content')).to eq("[hi](https://example.com)\n")
    end

    it 'converts an image to markdown syntax' do
      html = '<body><div id="content"><img src="https://example.com/x.png" alt="alt text"></div></body>'
      expect(converter.convert(html, selector: '#content')).to eq("![alt text](https://example.com/x.png)\n")
    end

    it 'strips configured selectors before converting' do
      html = '<body><div id="content">keep<script>remove me</script></div></body>'
      expect(converter.convert(html, selector: '#content')).to eq("keep\n")
    end

    it 'converts the whole body when no selector is given' do
      html = '<html><body><p>a</p><p>b</p></body></html>'
      expect(converter.convert(html)).to eq("a\n\nb\n")
    end

    it 'returns nil when the selector matches nothing' do
      html = '<body><div id="other">x</div></body>'
      expect(converter.convert(html, selector: '#content')).to be_nil
    end

    it 'returns nil when the converted content is blank' do
      html = '<body><div id="content">   </div></body>'
      expect(converter.convert(html, selector: '#content')).to be_nil
    end
  end

  describe '.md_url_for' do
    it 'maps the root url to /index.md' do
      expect(described_class.md_url_for('/')).to eq('/index.md')
    end

    it 'maps a trailing-slash url to a sibling .md' do
      expect(described_class.md_url_for('/about/')).to eq('/about.md')
    end

    it 'maps an .html url to .md' do
      expect(described_class.md_url_for('/2026/01/01/post.html')).to eq('/2026/01/01/post.md')
    end

    it 'appends .md to a url without an extension' do
      expect(described_class.md_url_for('/feed')).to eq('/feed.md')
    end
  end
end
