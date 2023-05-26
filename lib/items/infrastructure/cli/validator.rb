# frozen_string_literal: true

require './lib/shared/messages'

module Items
  module Infrastructure
    module Cli
      class Validator
        def call(input)
          # this is not the best approach to control the input data and user will not have a good experience.
          # One option is to accumulate the errors and display them all together.
          # we are dealing with monads and complex type of data when we want to validate external data.
          # we would improve (TODO) the user experience returning all errors toguether in one array from the controller.

          # I use a Result class as interface of this implementation.
          # As i explained in the controller, file we use dry-monads/dry-transaction in our current company/real-project

          # These validations are deterministic/static (not changing often) that's why we validate outside of domain.
          # THE DOMAIN LAYER MUST ALWAYS RECEIVE VALID DATA...
          # it would be business rules and not simple validations if validations depend on the states of the system.
          input.any? || (return { value: false, message: Shared::Messages::NO_ARGUMENTS_ERROR })
          input.length == Shared::Messages::ONE || (return { value: false,
                                                             message: Shared::Messages::ARGUMENTS_COUNT_ERROR })
          !input.first.empty? || (return { value: false, message: Shared::Messages::EMPTY_CODES_ERROR })
          input.first.count(' ').zero? || (return { value: false,
                                                    message: Shared::Messages::EMPTY_SPACES_ERROR })
          { value: true }
        end
      end
    end
  end
end
