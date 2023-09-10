# frozen_string_literal: true

require './lib/shared/price/discount/calculators/buy_one_get_one_free'
require './lib/items/domain/entity'
require './lib/pricing_rules/domain/entity'
require 'shared/monetizer'

describe Shared::Price::Discount::Calculators::BuyOneGetOneFree do
  subject(:buy_one_get_one_free) do
    described_class.new(options:).call
  end

  let(:item_entity_klass) { Items::Domain::Entity }
  let(:monetize_price) { Shared::Monetizer.new.for_cents_value(311_00) }
  let(:item_entity_instance) { instance_double(item_entity_klass, monetize_price:) }

  let(:pricing_rule_entity_klass) { PricingRules::Domain::Entity }
  let(:monetize_discount) { Shared::Monetizer.new.for_cents_value(311_00) }
  let(:pricing_rule_entity_instance) do
    instance_double(pricing_rule_entity_klass, monetize_discount:, calculate_total_discount:)
  end
  let(:options) do
    {
      quantity:,
      pricing_rule: pricing_rule_entity_instance,
      record: item_entity_instance
    }
  end

  before do
    allow(item_entity_klass).to receive(:new).and_return(item_entity_instance)
    allow(pricing_rule_entity_klass).to receive(:new).and_return(pricing_rule_entity_instance)
  end

  describe '#call' do
    context 'when calculate_total_discount is greater than zero' do
      let(:calculate_total_discount) { Shared::Monetizer.new.for_cents_value(311_00) }
      let(:quantity) { 2 }

      it 'returns 3.11' do
        expect(buy_one_get_one_free.to_f).to eq(3.11)
      end

      it 'calls calculate_total_discount method with the expected values' do
        buy_one_get_one_free
        expect(pricing_rule_entity_instance).to have_received(:calculate_total_discount)
          .with(2, Shared::Monetizer.new.for_cents_value(311_00)).once
      end
    end

    context 'when calculate_total_discount is 0' do
      let(:calculate_total_discount) { Shared::Monetizer.new.for_cents_value(0) }
      let(:quantity) { 1 }

      it 'returns 0' do
        expect(buy_one_get_one_free.to_f).to eq(0)
      end

      it 'calls calculate_total_discount method with the expected values' do
        buy_one_get_one_free
        expect(pricing_rule_entity_instance).to have_received(:calculate_total_discount)
          .with(1, Shared::Monetizer.new.for_cents_value(311_00)).once
      end
    end
  end
end
