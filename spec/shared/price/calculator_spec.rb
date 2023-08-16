# frozen_string_literal: true

require './lib/shared/price/calculator'
require './lib/shared/price/discount/calculators_data'
require './lib/items/domain/entity'
require './lib/promotions/domain/entity'
require './lib/pricing_rules/domain/entity'

describe Shared::Price::Calculator do
  subject(:calculator) do
    described_class.new.call(
      records,
      calculables,
      pricing_rules,
      grouped_codes_tally
    )
  end

  let(:item_entity_klass) { Items::Domain::Entity }
  let(:gr1_item_entity_instance) do
    instance_double(item_entity_klass, id: 1, code: 'GR1', price: 311_00, promotion_id: 1, entity_name: :item,
                                       calculate_total_price: 3.11)
  end
  let(:ttt_item_entity_instance) do
    instance_double(item_entity_klass, id: 2, code: 'TTT', price: 600_00, promotion_id: nil, entity_name: :item,
                                       calculate_total_price: 12.00)
  end

  let(:promotion_entity_klass) { Promotions::Domain::Entity }
  let(:gr1_promotion_entity_instance) do
    instance_double(promotion_entity_klass,
                    { id: 1, name: 'Buy one, get one free', slug: 'buy-one-get-one-free', entity_name: :promotion })
  end

  let(:pricing_rule_entity_klass) { PricingRules::Domain::Entity }
  let(:gr1_pricing_rule_entity_instance) do
    instance_double(pricing_rule_entity_klass,
                    { id: 1, promotion_id: 1, item_id: 1, qty_min: 2, qty_max: 2, discount: 311_00,
                      entity_name: :pricing_rule })
  end

  let(:records) { [gr1_item_entity_instance, ttt_item_entity_instance] }
  let(:calculables) { [gr1_promotion_entity_instance] }
  let(:pricing_rules) { [gr1_pricing_rule_entity_instance] }

  let(:grouped_codes_tally) { { 'GR1' => 2, 'TTT' => 2 } }
  let(:gr1_discount) { 3.11 }

  let(:discount_calculator_klass) { Shared::Price::Discount::Calculator }
  let(:discount_calculator_instance) { instance_double(discount_calculator_klass) }

  before do
    allow(discount_calculator_klass).to receive(:new).and_return(discount_calculator_instance)
  end

  it 'calls calculate_total_price method of the gr1 record with the expected attributes' do
    allow(discount_calculator_instance).to receive(:call).and_return(3.11)

    calculator

    expect(gr1_item_entity_instance).to have_received(:calculate_total_price).with(2, 3.11).once
  end

  it 'calls calculate_total_price method of the ttt record with the expected attributes' do
    allow(discount_calculator_instance).to receive(:call).and_return(0.0)

    calculator

    expect(ttt_item_entity_instance).to have_received(:calculate_total_price).with(2, 0.0).once
  end

  it 'returns 15.11' do
    allow(discount_calculator_instance).to receive(:call).and_return(3.11)

    expect(calculator).to eq(15.11)
  end

  it 'calls the discount_calculator_instance with the expected arguments for every record' do
    discount_calculator_instance_arguments = [
      [gr1_item_entity_instance, 2, gr1_pricing_rule_entity_instance, gr1_promotion_entity_instance],
      [ttt_item_entity_instance, 2, nil, nil]
    ]

    allow(discount_calculator_instance).to receive(:call).and_return(0.0)

    calculator

    discount_calculator_instance_arguments.each do |array|
      expect(discount_calculator_instance).to have_received(:call).with(*array).once
    end
  end
end
