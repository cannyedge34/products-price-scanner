# frozen_string_literal: true

require './lib/promotions/domain/repository'
require './lib/items/domain/repository'
require './lib/pricing_rules/domain/repository'

module Shared
  module Db
    module RepositoriesFactory
      DEFAULT_REPOSITORIES_DATA = [
        { entity: :item, klass: Items::Domain::Repository },
        { entity: :promotion, klass: Promotions::Domain::Repository },
        { entity: :pricing_rule, klass: PricingRules::Domain::Repository }
      ].freeze

      def self.build(repositories_data = DEFAULT_REPOSITORIES_DATA)
        repositories_data.map do |repository_data|
          Struct.new(:entity, :instance).new(repository_data[:entity], repository_data[:klass].new)
        end
      end
    end
  end
end
