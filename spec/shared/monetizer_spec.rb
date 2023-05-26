# frozen_string_literal: true

require 'shared/monetizer'

describe Shared::Monetizer do
  subject(:monetizer) { described_class.new }

  describe '#value' do
    let(:cents) { 311_00 }

    it 'returns the default monetized value' do
      expect(monetizer.for_cents_value(cents)).to be_a(Money)
    end
  end

  describe '#for_amount_value' do
    let(:amount) { '3.11' }

    it 'returns the default monetized value' do
      expect(monetizer.for_amount_value(amount)).to eq('€3.11')
    end
  end
end
