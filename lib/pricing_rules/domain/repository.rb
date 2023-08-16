# frozen_string_literal: true

require_relative '../../shared/db/in_memory'
require_relative './entity'

module PricingRules
  module Domain
    class Repository
      def initialize(data_source: Shared::Db::InMemory.instance.db.from(:pricing_rules))
        @data_source = data_source
      end

      def where(attributes)
        data_source.where(attributes).map { |pricing_rule| PricingRules::Domain::Entity.new(pricing_rule) }
      end

      private

      attr_reader :data_source
    end
  end
end
