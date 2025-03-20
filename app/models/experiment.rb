# frozen_string_literal: true

class Experiment < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :dataset, inverse_of: :experiments
  belongs_to :llm, inverse_of: :experiments

  has_many :results, inverse_of: :experiment, dependent: :destroy

  validates :system_prompt, presence: true
  validate :llm_allowed, if: -> { llm.present? && dataset.present? }

  private def llm_allowed
    return if llm.deployed_by_user.nil?
    return if llm.deployed_by_user == dataset.user

    errors.add(:llm_id, :deployed_by_wrong_user)
  end
end
