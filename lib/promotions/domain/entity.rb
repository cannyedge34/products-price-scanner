# frozen_string_literal: true

# TODO: add missing tests, (i will not spend time adding test here)

module Promotions
  module Domain
    class Entity
      def initialize(args)
        # we should not share the internal id with other services, we can share an uuid
        @id = args[:id]
        @name = args[:name]
        @slug = args[:slug]
      end

      def entity_name
        :promotion
      end

      # Anemic domain model is not an anti-pattern unless we think we really have a domain model.
      attr_reader :id, :name, :slug
    end
  end
end
