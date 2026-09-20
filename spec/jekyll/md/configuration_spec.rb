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
    it { expect(config.layout).to be_nil }
    it { expect(config.layout_for(item)).to be_nil }
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

  describe 'layout' do
    it 'has no layout by default' do
      config = described_class.new({})
      expect(config.layout_for(item)).to be_nil
    end

    it 'uses the site-wide layout' do
      config = described_class.new('layout' => 'md_page')
      expect(config.layout_for(item)).to eq('md_page')
    end

    it 'overrides the site-wide layout via md_layout' do
      config = described_class.new('layout' => 'md_page')
      custom = double('item', url: '/foo/', data: { 'md_layout' => 'md_alt' }) # rubocop:disable RSpec/VerifiedDoubles
      expect(config.layout_for(custom)).to eq('md_alt')
    end

    it 'opts a page out of a site-wide layout via md_layout: false' do
      config = described_class.new('layout' => 'md_page')
      opted_out = double('item', url: '/foo/', data: { 'md_layout' => false }) # rubocop:disable RSpec/VerifiedDoubles
      expect(config.layout_for(opted_out)).to be(false)
    end
  end
end
