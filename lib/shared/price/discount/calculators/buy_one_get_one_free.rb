# frozen_string_literal: true

require './lib/shared/accumulator'

module Shared
  module Price
    module Discount
      module Calculators
        class BuyOneGetOneFree
          def initialize(options:, accumulator: Shared::Accumulator.new)
            @quantity = options[:quantity]
            @pricing_rule = options[:pricing_rule]
            @accumulator = accumulator
          end

          def call
            discounts = [pricing_rule.calculate_total_discount(quantity, pricing_rule.monetize_discount)]

            accumulator.call(discounts)
          end

          private

          attr_reader :quantity, :pricing_rule, :accumulator
        end
      end
    end
  end
end
