# frozen_string_literal: true

module Results
  class CancelService
    def initialize(result:)
      @result = result
    end

    def call
      @result.cancel! # returns true
    rescue AASM::InvalidTransition
      false
    end
  end
end
