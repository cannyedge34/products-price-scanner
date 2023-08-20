# frozen_string_literal: true

require 'items/infrastructure/cli/validator'
require 'shared/result'

describe Shared::Result do
  subject(:result) { described_class.new(validator: validator_instance, params:) }

  let(:validator_klass) { Items::Infrastructure::Cli::Validator }
  let(:validator_instance) { instance_double(validator_klass) }
  let(:params) { nil }

  before { allow(validator_klass).to receive(:new).and_return(validator_instance) }

  describe '#valid?' do
    context 'when validator value return true' do
      before { allow(validator_instance).to receive(:call).and_return({ value: true }) }

      it 'returns true' do
        expect(result.valid?).to eq(true)
      end
    end

    context 'when validator value return false' do
      before { allow(validator_instance).to receive(:call).and_return({ value: false }) }

      it 'returns false' do
        expect(result.valid?).to eq(false)
      end
    end
  end

  describe '#error' do
    context 'when validator returns an error message' do
      before { allow(validator_instance).to receive(:call).and_return({ message: 'any message' }) }

      it 'returns the validator message' do
        expect(result.error).to eq('any message')
      end
    end

    context 'when validator does not returns an error message' do
      before { allow(validator_instance).to receive(:call).and_return({}) }

      it 'returns nil' do
        expect(result.error).to be_nil
      end
    end
  end
end
