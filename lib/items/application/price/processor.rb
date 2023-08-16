# frozen_string_literal: true

require './lib/shared/messages'
require './lib/shared/result'
require './lib/shared/db/repositories_factory'
require './lib/shared/price/calculator'
require_relative '../codes/validator'

module Items
  module Application
    module Price
      class Processor
        # we inject the repositories in the use case (application layer) when we use hexagonal architecture

        def initialize(
          repositories_factory: Shared::Db::RepositoriesFactory.build,
          codes_validator: Items::Application::Codes::Validator.new,
          price_calculator: Shared::Price::Calculator.new
        )
          @items_repository = repositories_factory.find { |data| data.entity == :item }.instance
          @promotions_repository = repositories_factory.find { |data| data.entity == :promotion }.instance
          @pricing_rules_repository = repositories_factory.find { |data| data.entity == :pricing_rule }.instance
          @codes_validator = codes_validator
          @price_calculator = price_calculator
        end

        # The responsability of this class is something like coordinate the collaboration
        # of the injected objects in order to accomplish its own goal https://youtu.be/XXi_FBrZQiU?t=2304
        # https://www.deconstructconf.com/2018/sandi-metz-polly-want-a-message min 38:09

        def call(items_codes_dto)
          items = items_repository.where(code: items_codes_dto.codes)
          grouped_codes_tally = items_codes_dto.codes.tally

          # This result object is here because is more a business rule.
          # and we have the repositories injected in this application service.
          # Business rules are not static as validations of validator.rb of infrastructure/cli folder
          # This validation often depends/is-based on the state of the system.
          # We can not inject the repository in the controller to keep decoupled infrastructure/application layers.
          result = Shared::Result.new(params: items, validator: codes_validator)

          return Shared::Messages.print(result.error) unless result.valid?

          promotions = promotions_repository.where(id: items.map(&:promotion_id))

          pricing_rules = pricing_rules_repository.where(promotion_id: promotions.map(&:id), item_id: items.map(&:id))

          price_calculator.call(items, promotions, pricing_rules, grouped_codes_tally)
        end

        private

        attr_reader :items_repository,
                    :promotions_repository,
                    :pricing_rules_repository,
                    :codes_validator,
                    :price_calculator
      end
    end
  end
end
