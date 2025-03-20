# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry unhandled exceptions for up to a week with exponential backoff
  retry_on Exception, attempts: 20, wait: :polynomially_longer

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # Concurrency safety
  self.enqueue_after_transaction_commit = true
end
