# frozen_string_literal: true

require 'spec_helper'

describe Jekyll::Md::LayoutRenderer do
  subject(:renderer) { described_class.new }

  let(:site) do
    double('site', site_payload: { 'site' => { 'title' => 'My Site' } }, layouts: layouts) # rubocop:disable RSpec/VerifiedDoubles
  end

  let(:layouts) { {} }

  let(:item) do
    double('item', to_liquid: { 'title' => 'Hello World', 'url' => '/hello/' }) # rubocop:disable RSpec/VerifiedDoubles
  end

  def stub_layout(name, content)
    layouts[name] = double('layout', content: content) # rubocop:disable RSpec/VerifiedDoubles
  end

  it 'renders content in place' do
    stub_layout('md_page', '{{ content }}')
    markdown = renderer.render('md_page', 'Hello.', item, site)
    expect(markdown).to eq('Hello.')
  end

  it 'exposes page front matter' do
    stub_layout('md_page', '# {{ page.title }}')
    markdown = renderer.render('md_page', 'Hello.', item, site)
    expect(markdown).to eq('# Hello World')
  end

  it 'exposes site config' do
    stub_layout('md_page', '{{ site.title }}')
    markdown = renderer.render('md_page', 'Hello.', item, site)
    expect(markdown).to eq('My Site')
  end

  it 'combines a heading, the content, and a footer' do
    stub_layout('md_page', "# {{ page.title }}\n\n{{ content }}\n\nSource: {{ page.url }}")
    markdown = renderer.render('md_page', 'Hello.', item, site)
    expect(markdown).to eq("# Hello World\n\nHello.\n\nSource: /hello/")
  end

  it 'caches the parsed layout across calls' do
    stub_layout('md_page', '{{ content }}')
    allow(Liquid::Template).to receive(:parse).with('{{ content }}').and_call_original

    renderer.render('md_page', 'One.', item, site)
    renderer.render('md_page', 'Two.', item, site)

    expect(Liquid::Template).to have_received(:parse).with('{{ content }}').once
  end

  it 'raises when the layout does not exist' do
    expect { renderer.render('missing', 'Hello.', item, site) }.to raise_error(/layout not found: missing/)
  end
end
