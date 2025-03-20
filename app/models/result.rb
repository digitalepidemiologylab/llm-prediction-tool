# frozen_string_literal: true

class Result < ApplicationRecord
  self.implicit_order_column = :created_at

  include AASM

  belongs_to :experiment, inverse_of: :results

  aasm column: :status, no_direct_assignment: true, whiny_persistence: true do
    state :initial, initial: true
    state :processing
    state :ready
    state :failed
    state :cancelled

    event :process do
      transitions from: :initial, to: :processing
    end

    event :complete do
      transitions from: :processing, to: :ready
    end

    event :fail do
      transitions from: :processing, to: :failed
    end

    event :cancel do
      transitions from: %i[initial processing], to: :cancelled
    end
  end

  def final?
    %i[ready failed cancelled].include?(status.to_sym)
  end
end
