# frozen_string_literal: true

require_relative './calculators/buy_one_get_one_free'
require_relative './calculators/bulk_purchase'

module Shared
  module Price
    module Discount
      module CalculatorsData
        def self.build
          {
            'buy-one-get-one-free' => Shared::Price::Discount::Calculators::BuyOneGetOneFree,
            'bulk-purchase' => Shared::Price::Discount::Calculators::BulkPurchase
          }
        end
      end
    end
  end
end
