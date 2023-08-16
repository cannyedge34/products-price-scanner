# frozen_string_literal: true

require './lib/shared/messages'

module Items
  module Application
    module Codes
      class Validator
        def call(codes)
          codes.any? || (return { value: false, message: Shared::Messages::NOT_FOUND_ITEMS_ERROR })
          { value: true }
        end
      end
    end
  end
end
