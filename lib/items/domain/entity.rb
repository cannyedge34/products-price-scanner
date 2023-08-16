# frozen_string_literal: true

# TODO: add missing tests, (i will not spend time adding test here)

require './lib/shared/monetizer'

module Items
  module Domain
    class Entity
      def initialize(args, monetizer: Shared::Monetizer.new)
        # we should not share the internal id with other services, we can share an uuid
        @id = args[:id]
        @code = args[:code]
        @price = args[:price]
        @promotion_id = args[:promotion_id]
        @monetizer = monetizer
      end

      def calculate_total_price(quantity, discount)
        (monetize_price.to_f * quantity) - discount.to_f
      end

      def monetize_price
        monetizer.for_cents_value(price)
      end

      def entity_name
        :item
      end

      attr_reader :id, :code, :price, :promotion_id

      private

      attr_reader :monetizer
    end
  end
end
