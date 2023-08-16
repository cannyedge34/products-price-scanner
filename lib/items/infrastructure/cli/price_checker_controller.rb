# frozen_string_literal: true

# TODO: add missing tests, (i will not spend time adding test here)
require './lib/shared/result'
require_relative './validator'
require_relative './output'
require_relative '../../application/price/processor'

module Items
  module Infrastructure
    module Cli
      class PriceCheckerController
        ::Items::Codes = Struct.new(:codes)

        def initialize(
          params:,
          validator: Validator.new,
          output: Output.new,
          processor: ::Items::Application::Price::Processor.new
        )
          @params = params
          # this validator is explicit for user experience of a cli (infrastructure),
          # item entity validations are contained in value objects of the domain layer, id_vo, code_vo and price_vo
          # these value_objects prevent the antipattern shotgun surgery containing all validation rules in these objects
          # we want to disallow instantiations of any item entity
          # that do not comply with the integrity constraints of the domain rules.

          # we need to enforce the invariants in the domain layer (business rules) and they are not trivial validations.
          # but we need to validate these trivial validations outside of the domain (validations are not br) and YES,
          # we can/should "repeat" some logic (it's not a BAD NOT APPLING DRY) in this case
          # for trivial/static/deterministic validations in infrastructure (controller)
          # and business rules (usually value objects validations) in domain layer.

          @validator = validator
          @output = output
          @processor = processor
        end

        def call
          # Company with scalability needs move from hexagonal architecture to cqrs... it would be something like:

          # 1. the controller instantiates a command/query/dto
          # 2. this command/query is sent to the bus.
          # 3. the query/command bus maps the handler with the locator pattern (1 to 1 association)
          # 4. the handler has injected the use_case/service
          # 5. query/command bus delivers the query/command to the handler
          # 6. the handler maps the primitive values (received data-transfer-objects) and return value_objects instances
          # 7. the handler sends these value objects to the injected use case (processor in this case).

          # IMPORTANT i'm not gonna send "items_codes" value_object calling the service/use_case
          # because i'm not using handlers to decouple infrastructure/controller from the application/use_case layer.
          # The handler is part of the application layer and the "Bus" is part of the infrastructure layer.
          # I use a DTO/Struct to send a message to the service/use_case

          # i use the result pattern instead of exceptions.
          # Usually we work with dry-monads/dry-transactions in my current company.

          # This dependency Shared::Result.new is not very harmful, since it is a utility class used system wide.
          result = Shared::Result.new(params:, validator:)

          return output.call(processor.call(Items::Codes.new(params.first.split(',')))) if result.valid?

          Shared::Messages.print(result.error)
        end

        private

        attr_reader :params, :result, :validator, :output, :processor
      end
    end
  end
end
