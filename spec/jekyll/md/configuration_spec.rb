# frozen_string_literal: true

require 'spec_helper'

describe Jekyll::Md::Configuration do
  let(:item) { double('item', url: '/foo/', data: {}) } # rubocop:disable RSpec/VerifiedDoubles

  describe 'defaults' do
    subject(:config) { described_class.new({}) }

    it { expect(config.enabled?).to be(true) }
    it { expect(config.link?).to be(true) }
    it { expect(config.selector).to be_nil }
    it { expect(config.strip_selectors).to eq(%w[script style]) }
    it { expect(config.enabled_for?(item)).to be(true) }
    it { expect(config.link_for?(item)).to be(true) }
    it { expect(config.selector_for(item)).to be_nil }
    it { expect(config.frontmatter_fields_for(item)).to eq([]) }
  end

  describe 'site-wide overrides' do
    subject(:config) { described_class.new('enabled' => false, 'link' => false, 'selector' => '#content') }

    it { expect(config.enabled?).to be(false) }
    it { expect(config.link?).to be(false) }
    it { expect(config.selector).to eq('#content') }
    it { expect(config.enabled_for?(item)).to be(false) }
  end

  describe 'exclusions' do
    subject(:config) { described_class.new('exclude' => ['/foo/*']) }

    it 'excludes matching urls' do
      expect(config.excluded?('/foo/bar')).to be(true)
    end

    it 'does not exclude non-matching urls' do
      expect(config.excluded?('/other')).to be(false)
    end
  end

  describe 'per-page overrides' do
    subject(:config) { described_class.new({}) }

    it 'opts a page out via md: false' do
      opted_out = double('item', url: '/foo/', data: { 'md' => false }) # rubocop:disable RSpec/VerifiedDoubles
      expect(config.enabled_for?(opted_out)).to be(false)
    end

    it 'disables the link tag via md_link: false' do
      no_link = double('item', url: '/foo/', data: { 'md_link' => false }) # rubocop:disable RSpec/VerifiedDoubles
      expect(config.link_for?(no_link)).to be(false)
    end

    it 'overrides the selector via md_selector' do
      custom = double('item', url: '/foo/', data: { 'md_selector' => '#custom' }) # rubocop:disable RSpec/VerifiedDoubles
      expect(config.selector_for(custom)).to eq('#custom')
    end
  end

  describe 'front matter fields' do
    it 'is empty by default' do
      config = described_class.new({})
      expect(config.frontmatter_fields_for(item)).to eq([])
    end

    it 'uses the default field set when enabled site-wide with true' do
      config = described_class.new('frontmatter' => true)
      expect(config.frontmatter_fields_for(item)).to eq(%w[title date tags])
    end

    it 'uses an explicit list of fields configured site-wide' do
      config = described_class.new('frontmatter' => %w[title url])
      expect(config.frontmatter_fields_for(item)).to eq(%w[title url])
    end

    it 'ignores unknown field names' do
      config = described_class.new('frontmatter' => %w[title bogus])
      expect(config.frontmatter_fields_for(item)).to eq(%w[title])
    end

    it 'can be enabled per-page via md_frontmatter: true' do
      config = described_class.new({})
      opted_in = double('item', url: '/foo/', data: { 'md_frontmatter' => true }) # rubocop:disable RSpec/VerifiedDoubles
      expect(config.frontmatter_fields_for(opted_in)).to eq(%w[title date tags])
    end

    it 'can be set per-page to an explicit list, overriding the site-wide default' do
      config = described_class.new('frontmatter' => true)
      custom = double('item', url: '/foo/', data: { 'md_frontmatter' => %w[title] }) # rubocop:disable RSpec/VerifiedDoubles
      expect(config.frontmatter_fields_for(custom)).to eq(%w[title])
    end

    it 'can be disabled per-page via md_frontmatter: false when on site-wide' do
      config = described_class.new('frontmatter' => true)
      opted_out = double('item', url: '/foo/', data: { 'md_frontmatter' => false }) # rubocop:disable RSpec/VerifiedDoubles
      expect(config.frontmatter_fields_for(opted_out)).to eq([])
    end
  end
end
