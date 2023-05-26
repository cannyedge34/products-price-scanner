# frozen_string_literal: true

require 'items/infrastructure/cli/validator'

describe Items::Infrastructure::Cli::Validator do
  subject(:validator) { described_class.new.call(input) }

  describe '.call' do
    context 'when input is empty' do
      let(:input) { [] }

      it 'returns no argument error message' do
        expect(validator).to eq({ value: false, message: 'Can not proceed without argument.' })
      end
    end

    context 'when input has more than one argument' do
      let(:input) { ['SR1,SR2', 'second argument'] }

      it 'returns arguments count error message' do
        expect(validator).to eq({ value: false, message: 'Cannot proceed with more than one argument.' })
      end
    end

    context 'when input has empty string' do
      let(:input) { [''] }

      it 'returns empty codes error message' do
        expect(validator).to eq({ value: false, message: 'At least one item id needed.' })
      end
    end

    context 'when input has spaces' do
      let(:input) { ['GR1, GR1'] }

      it 'returns empty spaces error message' do
        expect(validator).to eq(
          { value: false, message: 'There should be no spaces between commas, example: "GR1,GR1,GR1"' }
        )
      end
    end

    context 'when input has a valid string' do
      let(:input) { ['SR1,SR2'] }

      it 'returns true' do
        expect(validator).to eq({ value: true })
      end
    end
  end
end
