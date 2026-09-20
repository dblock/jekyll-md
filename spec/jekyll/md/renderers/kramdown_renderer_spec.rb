# frozen_string_literal: true

require 'spec_helper'

describe Jekyll::Md::Renderers::Kramdown do
  subject(:renderer) { described_class.new }

  it 'converts a link using reference style, not inline' do
    expect(renderer.render('<a href="https://example.com">hi</a>')).to eq("[hi][1]\n\n[1]: https://example.com\n")
  end

  it 'converts a code block using indentation, not fences' do
    expect(renderer.render('<pre><code>a</code></pre>')).to eq("    a\n\n")
  end

  it 'falls back to raw HTML for a table' do
    html = '<table><tr><th>A</th></tr></table>'
    expect(renderer.render(html)).to include('<table>')
  end
end
