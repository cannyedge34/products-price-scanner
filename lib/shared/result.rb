# frozen_string_literal: true

module Shared
  class Result
    # This result pattern is very used overall in Rust.
    # I did a small resume of how this pattern is used learning rust in this link:
    # https://github.com/cannyedge34/rust-course/blob/master/6-pattern-matching/type-parameters.rs
    # As i mentioned in other file, we use a more sophisticated gem in our current company as dry-monads/dry-transaction

    def initialize(params:, validator:)
      @params = params
      @validator = validator
    end

    def valid?
      validator.call(params)[:value]
    end

    def error
      validator.call(params)[:message]
    end

    private

    attr_reader :params, :validator
  end
end
