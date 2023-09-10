# frozen_string_literal: true

require './lib/shared/accumulator'

module Shared
  module Price
    module Discount
      module Calculators
        class BulkPurchase
          def initialize(options:, accumulator: Shared::Accumulator.new)
            @quantity = options[:quantity]
            @pricing_rule = options[:pricing_rule]
            @record = options[:record]
            @accumulator = accumulator
          end

          def call
            discounts = [pricing_rule.calculate_total_discount(quantity, discount(pricing_rule.monetize_discount))]

            # calculate_total_discount or monetize_discount names refer to "TELL, DONT ASK" principle,
            # principle suggests that it is better to issue an object a command do perform some operation or logic,
            # rather than to query its state and then take some action as a result.

            # more useful info about concepts of tell don't ask and other important concepts:
            # http://docs.eventide-project.org/user-guide/useful-objects.html#null-object-dependencies-and-useful-objects

            accumulator.call(discounts)
          end

          private

          attr_reader :quantity, :pricing_rule, :record, :accumulator

          def discount(pricing_rule_discount)
            (record.monetize_price * pricing_rule_discount.to_f / Shared::Messages::ONE_HUNDRED) * quantity
          end
        end
      end
    end
  end
end
