# frozen_string_literal: true

# TODO: add missing tests, (i will not spend time adding test here)

require './lib/shared/monetizer'

module PricingRules
  module Domain
    class Entity
      def initialize(args, monetizer: Shared::Monetizer.new)
        # we should not share the internal id with other bounded-contexts/services, we can share an uuids
        # however in distributed systems we can share the same physical database but not logically.
        @id = args[:id]
        @promotion_id = args[:promotion_id]
        @item_id = args[:item_id]
        @qty_min = args[:qty_min]
        @qty_max = args[:qty_max]
        @discount = args[:discount]
        @monetizer = monetizer
      end

      def calculate_total_discount(quantity, discount)
        (cover_quantity?(quantity) && discount) || Shared::Messages::ZERO
      end

      def monetize_discount
        monetizer.for_cents_value(discount)
      end

      def entity_name
        :pricing_rule
      end

      attr_reader :id, :item_id, :promotion_id, :qty_min, :qty_max, :discount

      private

      attr_reader :monetizer

      def cover_quantity?(quantity)
        (qty_min..qty_max).cover?(quantity)
      end
    end
  end
end
