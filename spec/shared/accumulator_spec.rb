# frozen_string_literal: true

require 'shared/accumulator'

describe Shared::Accumulator do
  subject(:accumulator) { described_class.new.call(accumulable) }

  let(:accumulable) { [1, 2, 3] }

  it 'accumulates the received accumulable data' do
    expect(accumulator).to eq(6)
  end
end
