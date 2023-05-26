# frozen_string_literal: true

require './lib/shared/monetizer'
require './lib/shared/messages'

module Items
  module Infrastructure
    module Cli
      class Output
        def initialize(monetizer: Shared::Monetizer.new)
          @monetizer = monetizer
        end

        def call(price)
          puts "#{Shared::Messages::EXPECTED_TOTAL_PRICE} #{monetizer.for_amount_value(price)}"
        end

        private

        attr_reader :monetizer
      end
    end
  end
end
