# frozen_string_literal: true

require 'items/application/codes/validator'

describe Items::Application::Codes::Validator do
  subject(:validator) { described_class.new.call(items) }

  context 'when items is not empty' do
    let(:items) { %w[GR1] }

    it 'returns true' do
      expect(validator).to eq({ value: true })
    end
  end

  context 'when items empty' do
    let(:items) { %w[] }

    it 'returns not found items error message' do
      expect(validator).to eq({ value: false, message: 'Received items codes do not exist in the database!' })
    end
  end
end
