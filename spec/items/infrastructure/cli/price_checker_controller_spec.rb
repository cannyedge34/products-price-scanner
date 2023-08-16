# frozen_string_literal: true

require 'items/infrastructure/cli/price_checker_controller'

describe Items::Infrastructure::Cli::PriceCheckerController do
  subject(:controller) { described_class.new(params:).call }

  # usually we should not mock controller tests since we need
  # to test the feature e2e in this layer.
  # But we are testing the whole flow in this spec cli_check_items_price_spec
  # (from the more external layer until the shown result in the console)
  # i will stub the message to know when we receive valid/invalid params

  let(:message_klass) { Shared::Messages }
  let(:processor_klass) { Items::Application::Price::Processor }
  let(:processor_instance) { instance_double(processor_klass, call: nil) }
  let(:result_klass) { Shared::Result }
  let(:result_instance) { instance_double(result_klass) }

  let(:output_klass) { Items::Infrastructure::Cli::Output }
  let(:output_instance) { instance_double(output_klass, call: nil) }

  before do
    allow(message_klass).to receive(:print)
    allow(processor_klass).to receive(:new).and_return(processor_instance)
    allow(result_klass).to receive(:new).and_return(result_instance)
    allow(output_klass).to receive(:new).and_return(output_instance)
  end

  context 'when params has a valid format' do
    let(:params) { ['GR1,GR1'] }

    before do
      allow(result_instance).to receive(:valid?).and_return(true)
    end

    it 'does not print a message' do
      controller

      expect(message_klass).not_to have_received(:print)
    end

    it 'calls output instance' do
      controller

      expect(output_instance).to have_received(:call).with(nil)
    end
  end

  context 'when params has an invalid format' do
    let(:params) { ['GR1, GR1'] }

    before do
      allow(result_instance).to receive(:valid?).and_return(false)
      allow(result_instance).to receive(:error).and_return(
        'There should be no spaces between commas, example: "GR1,GR1,GR1"'
      )
    end

    it 'prints a message from messages' do
      controller

      expect(message_klass).to have_received(:print).with(
        'There should be no spaces between commas, example: "GR1,GR1,GR1"'
      )
    end

    it 'does not output any text' do
      controller

      expect(output_instance).not_to have_received(:call)
    end
  end
end
