# frozen_string_literal: true

require 'spec_helper'

describe Jekyll::Md::Renderer do
  describe '.for' do
    it 'returns a ReverseMarkdown renderer by default name' do
      expect(described_class.for('reverse_markdown')).to be_a(Jekyll::Md::Renderers::ReverseMarkdown)
    end

    it 'returns a Kramdown renderer' do
      expect(described_class.for('kramdown')).to be_a(Jekyll::Md::Renderers::Kramdown)
    end

    it 'returns an HtmlToMarkdown renderer' do
      expect(described_class.for('html-to-markdown')).to be_a(Jekyll::Md::Renderers::HtmlToMarkdown)
    end

    it 'raises for an unknown renderer name' do
      expect { described_class.for('nope') }.to raise_error(/unknown renderer/)
    end
  end
end
