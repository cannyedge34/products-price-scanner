# frozen_string_literal: true

require 'items/application/price/processor'

describe Items::Application::Price::Processor do
  subject(:processor) { described_class.new.call(items_codes_dto) }

  let(:items_codes_dto) { Struct.new(:codes).new(%w[GR1 GR1]) }
  let(:repositories_factory_klass) { Shared::Db::RepositoriesFactory }

  # We should mock the application layer specs, since we have the acceptance tests to test the whole flow.
  # Tests would be super slow if we hit the database in this layer too. Application layer -> Unit tests.

  let(:item_repository_klass) { Items::Domain::Repository }
  let(:item_repository_instance) { instance_double(item_repository_klass, where: []) }
  let(:promotion_repository_klass) { Promotions::Domain::Repository }
  let(:promotion_repository_instance) { instance_double(promotion_repository_klass, where: []) }
  let(:pricing_rule_repository_klass) { PricingRules::Domain::Repository }
  let(:pricing_rule_repository_instance) { instance_double(pricing_rule_repository_klass, where: []) }

  let(:repositories_data) do
    [
      Struct.new(:entity, :instance).new(:item, item_repository_instance),
      Struct.new(:entity, :instance).new(:promotion, promotion_repository_instance),
      Struct.new(:entity, :instance).new(:pricing_rule, pricing_rule_repository_instance)
    ]
  end

  let(:price_calculator_klass) { Shared::Price::Calculator }
  let(:price_calculator_instance) { instance_double(price_calculator_klass, call: nil) }
  let(:result_klass) { Shared::Result }
  let(:result_instance) { instance_double(result_klass) }

  before do
    allow(item_repository_klass).to receive(:new).and_return(item_repository_instance)
    allow(promotion_repository_klass).to receive(:new).and_return(promotion_repository_instance)
    allow(pricing_rule_repository_klass).to receive(:new).and_return(pricing_rule_repository_instance)
    allow(repositories_factory_klass).to receive(:build).and_return(repositories_data)
    allow(price_calculator_klass).to receive(:new).and_return(price_calculator_instance)
    allow(result_klass).to receive(:new).and_return(result_instance)
    allow(Shared::Messages).to receive(:print)
  end

  context 'when result is valid' do
    before do
      allow(result_instance).to receive(:valid?).and_return(true)
      allow(result_instance).to receive(:error).and_return(nil)
    end

    it 'calls the price_calculator with the expected arguments' do
      processor

      expect(price_calculator_instance).to have_received(:call).with(
        [], [], [], { 'GR1' => 2 }
      )
    end

    it 'does not print any error message' do
      processor

      expect(Shared::Messages).not_to have_received(:print)
    end
  end

  context 'when result is invalid' do
    before do
      allow(result_instance).to receive(:valid?).and_return(false)
      allow(result_instance).to receive(:error).and_return('any error')
    end

    it 'does not call the price_calculator' do
      processor

      expect(price_calculator_instance).not_to have_received(:call)
    end

    it 'prints an error message' do
      processor

      expect(Shared::Messages).to have_received(:print).with('any error')
    end
  end
end
