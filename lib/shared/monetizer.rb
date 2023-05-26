# frozen_string_literal: true

require 'money'
require './lib/shared/messages'

module Shared
  class Monetizer
    def initialize
      Money.locale_backend = nil
      Money.rounding_mode = BigDecimal::ROUND_HALF_UP
      Money.default_currency = Money::Currency.new('EUR')
    end

    def for_cents_value(amount)
      Money.from_cents(amount.to_f / Shared::Messages::ONE_HUNDRED)
    end

    def for_amount_value(amount)
      Money.from_cents(amount.to_f * Shared::Messages::ONE_HUNDRED).format
    end
  end
end
