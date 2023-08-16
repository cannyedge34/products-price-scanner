# frozen_string_literal: true

require './lib/shared/accumulator'
require './lib/promotions/shared/messages'
require './lib/shared/price/discount/calculator'

module Shared
  module Price
    class Calculator
      def initialize(
        accumulator: Shared::Accumulator.new,
        discount_calculator: Shared::Price::Discount::Calculator.new
      )
        @discount_calculator = discount_calculator
        @accumulator = accumulator
      end

      def call(records, calculables, pricing_rules, grouped_codes_tally)
        records_prices = records.map do |record|
          quantity = grouped_codes_tally[record.code]

          pricing_rule = pricing_rules.find do |pricing_rule_record|
            # i use a bit of metaprograming here to be able to reuse this calculator for example with an order
            pricing_rule_record.send("#{record.entity_name}_id") == record.id
          end

          calculable = calculables.find do |calculable_record|
            # calculable object can be a promotion for a item/order/user, shipping_cost/tax_rate for an order....
            # calculable is the role that a promotion plays for an item in this exercise.

            # links about polimorphism:
            # https://youtu.be/mpA2F1In41w?si=nw49dXsy6utG-K5e&t=2004
            # https://youtu.be/XXi_FBrZQiU?si=_f7vrbL2RGEUcsxu&t=1526
            calculable_record.id == record.send("#{calculable_record.entity_name}_id")
          end

          discount = discount_calculator.call(record, quantity, pricing_rule, calculable)

          record.calculate_total_price(quantity, accumulator.call([discount]))
        end

        accumulator.call(records_prices)
      end

      private

      attr_reader :accumulator, :discount_calculator
    end
  end
end
