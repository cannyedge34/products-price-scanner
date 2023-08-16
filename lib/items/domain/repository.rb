# frozen_string_literal: true

require_relative '../../shared/db/in_memory'
require_relative './entity'

# The repositories DO NOT raise exceptions!!
# it would be a different layer that if the value returned by the repository is nil or false,
# throws the exception, not from the repository!!

# TODO: Add specs hiting the database, thi is very important because we don't want to mock the implementation
# otherwise we would be errors if we change this implementation.
# SO, yes we need to do here integration tests including the implementation (no mocks)

module Items
  module Domain
    class Repository
      # we can use any implementation/adapter with this port/interface, changing data_source param
      def initialize(data_source: Shared::Db::InMemory.instance.db.from(:items))
        @data_source = data_source
      end

      def where(attributes)
        # By nature, a repository will instantiate entities/aggregates.
        # From infrastructure we call the domain layer. This is (coupling).
        # we are going to instantiate a Items.new in the infrastructure layer.
        # This coupling is assumed and is not as serious/dangerous as
        # if something in the domain layer depends on something in the infrastructure layer.
        data_source.where(attributes).map { |item| Items::Domain::Entity.new(item) }
      end

      private

      attr_reader :data_source
    end
  end
end
