# frozen_string_literal: true

require_relative '../../shared/db/in_memory'
require_relative './entity'

module Promotions
  module Domain
    class Repository
      def initialize(data_source: ::Shared::Db::InMemory.instance.db.from(:promotions))
        @data_source = data_source
      end

      def where(attributes)
        data_source.where(attributes).map { |promotion| Promotions::Domain::Entity.new(promotion) }
      end

      private

      attr_reader :data_source
    end
  end
end
