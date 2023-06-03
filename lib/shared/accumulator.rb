# frozen_string_literal: true

module Shared
  class Accumulator
    def call(acumulable)
      acumulable.inject(0) do |acc, number|
        acc += number
        acc
      end
    end
  end
end
