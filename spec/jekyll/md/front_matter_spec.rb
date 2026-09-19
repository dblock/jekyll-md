# frozen_string_literal: true

require 'spec_helper'

describe Jekyll::Md::FrontMatter do
  let(:site) { double('site', config: { 'url' => 'https://example.com', 'baseurl' => nil, 'author' => 'Site Author' }) } # rubocop:disable RSpec/VerifiedDoubles

  describe '#build' do
    it 'returns an empty string when no fields are configured' do
      item = double('item', url: '/about/', data: { 'title' => 'About' }) # rubocop:disable RSpec/VerifiedDoubles
      expect(described_class.new([]).build(item, site)).to eq('')
    end

    it 'builds a title field' do
      item = double('item', url: '/about/', data: { 'title' => 'About' }) # rubocop:disable RSpec/VerifiedDoubles
      expect(described_class.new(%w[title]).build(item, site)).to eq("---\ntitle: About\n---\n\n")
    end

    it 'builds a date field, formatting a Time as ISO 8601' do
      item = double('item', url: '/about/', data: { 'date' => Time.utc(2026, 1, 2, 3, 4, 5) }) # rubocop:disable RSpec/VerifiedDoubles
      markdown = described_class.new(%w[date]).build(item, site)
      expect(markdown).to include("date: '2026-01-02T03:04:05Z'")
    end

    it 'builds a tags field' do
      item = double('item', url: '/about/', data: { 'tags' => %w[ruby jekyll] }) # rubocop:disable RSpec/VerifiedDoubles
      markdown = described_class.new(%w[tags]).build(item, site)
      expect(markdown).to include("tags:\n- ruby\n- jekyll\n")
    end

    it 'builds a url field from site url + baseurl + item url' do
      item = double('item', url: '/about/', data: {}) # rubocop:disable RSpec/VerifiedDoubles
      markdown = described_class.new(%w[url]).build(item, site)
      expect(markdown).to include('url: https://example.com/about/')
    end

    it 'falls back to the site author when the item has none' do
      item = double('item', url: '/about/', data: {}) # rubocop:disable RSpec/VerifiedDoubles
      markdown = described_class.new(%w[author]).build(item, site)
      expect(markdown).to include('author: Site Author')
    end

    it 'prefers the item author over the site author' do
      item = double('item', url: '/about/', data: { 'author' => 'Item Author' }) # rubocop:disable RSpec/VerifiedDoubles
      markdown = described_class.new(%w[author]).build(item, site)
      expect(markdown).to include('author: Item Author')
    end

    it 'builds a description field' do
      item = double('item', url: '/about/', data: { 'description' => 'A short description.' }) # rubocop:disable RSpec/VerifiedDoubles
      markdown = described_class.new(%w[description]).build(item, site)
      expect(markdown).to include('description: A short description.')
    end

    it 'omits fields with no value' do
      no_author_site = double('site', config: { 'url' => 'https://example.com', 'baseurl' => nil }) # rubocop:disable RSpec/VerifiedDoubles
      item = double('item', url: '/about/', data: {}) # rubocop:disable RSpec/VerifiedDoubles
      expect(described_class.new(%w[title date tags author description]).build(item, no_author_site)).to eq('')
    end

    it 'builds multiple fields together' do
      item = double('item', url: '/about/', data: { 'title' => 'About', 'tags' => ['ruby'] }) # rubocop:disable RSpec/VerifiedDoubles
      markdown = described_class.new(%w[title tags]).build(item, site)
      expect(markdown).to eq("---\ntitle: About\ntags:\n- ruby\n---\n\n")
    end
  end
end
