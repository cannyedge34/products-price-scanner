# frozen_string_literal: true

require 'items/infrastructure/cli/price_checker_controller'
require 'shared/monetizer'

describe Items::Infrastructure::Cli::Output do
  subject(:outputt) { described_class.new.call(price) }

  let(:monetizer_constant) { Shared::Monetizer }
  let(:monetizer_instance) { instance_double(monetizer_constant, for_amount_value: '€0.25') }

  let(:price) { 2500 }

  before { allow(monetizer_constant).to receive(:new).and_return(monetizer_instance) }

  it 'prints the expected text' do
    expect { outputt }.to output(a_string_including('Expected total price €0.25')).to_stdout_from_any_process
  end
end
