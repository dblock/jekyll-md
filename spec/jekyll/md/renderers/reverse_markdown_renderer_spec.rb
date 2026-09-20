# frozen_string_literal: true

require 'spec_helper'

describe Jekyll::Md::Renderers::ReverseMarkdown do
  subject(:renderer) { described_class.new }

  it 'converts a link' do
    expect(renderer.render('<a href="https://example.com">hi</a>')).to eq('[hi](https://example.com)')
  end

  it 'converts a fenced code block' do
    expect(renderer.render('<pre><code>a</code></pre>').strip).to eq("```\na\n```")
  end

  it 'converts a table using GFM syntax' do
    html = '<table><tr><th>A</th></tr><tr><td>1</td></tr></table>'
    expect(renderer.render(html)).to include('| A |')
  end
end
