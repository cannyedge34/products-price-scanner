# frozen_string_literal: true

require './lib/shared/price/discount/calculators/bulk_purchase'
require './lib/items/domain/entity'
require './lib/pricing_rules/domain/entity'
require 'shared/monetizer'

describe Shared::Price::Discount::Calculators::BulkPurchase do
  subject(:bulk_purchase) do
    described_class.new(options:).call
  end

  let(:item_entity_klass) { Items::Domain::Entity }
  let(:monetize_price) { Shared::Monetizer.new.for_cents_value(500_00) }
  let(:sr1_item_entity_instance) { instance_double(item_entity_klass, monetize_price:) }

  let(:pricing_rule_entity_klass) { PricingRules::Domain::Entity }
  let(:monetize_discount) { Shared::Monetizer.new.for_cents_value(100_000) }
  let(:sr1_pricing_rule_entity_instance) do
    instance_double(pricing_rule_entity_klass, monetize_discount:, calculate_total_discount:)
  end

  let(:options) do
    {
      quantity:,
      pricing_rule: sr1_pricing_rule_entity_instance,
      record: sr1_item_entity_instance
    }
  end

  before do
    allow(item_entity_klass).to receive(:new).and_return(sr1_item_entity_instance)
    allow(pricing_rule_entity_klass).to receive(:new).and_return(sr1_pricing_rule_entity_instance)
  end

  describe '#call' do
    context 'when calculate_total_discount is greater than zero' do
      let(:calculate_total_discount) { Shared::Monetizer.new.for_cents_value(200_00) }
      let(:quantity) { 4 }

      it 'returns 2.0' do
        expect(bulk_purchase.to_f).to eq(2.0)
      end

      it 'calls calculate_total_discount method with the expected values' do
        bulk_purchase
        expect(sr1_pricing_rule_entity_instance).to have_received(:calculate_total_discount)
                                                .with(4, calculate_total_discount).once
      end
    end

    context 'when calculate_total_discount is zero' do
      let(:calculate_total_discount) { Shared::Monetizer.new.for_cents_value(0.0) }
      let(:quantity) { 2 }

      it 'returns 0' do
        expect(bulk_purchase.to_f).to eq(0.0)
      end

      it 'calls calculate_total_discount method with the expected values' do
        bulk_purchase
        expect(sr1_pricing_rule_entity_instance).to have_received(:calculate_total_discount)
                                                .with(2, Shared::Monetizer.new.for_cents_value(100_00)).once
      end
    end
  end
end
