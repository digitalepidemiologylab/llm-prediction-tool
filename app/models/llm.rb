# frozen_string_literal: true

class Llm < ApplicationRecord
  self.implicit_order_column = :created_at

  enum :provider, {
    anthropic: "anthropic",
    gemini: "gemini",
    huggingface: "huggingface",
    openai: "openai"
  }

  belongs_to :deployed_by_user, class_name: "User", optional: true, inverse_of: :deployed_llms

  has_many :experiments, inverse_of: :llm, dependent: :restrict_with_error

  validates :provider, presence: true # inclusion is implicit
  validates :name, presence: true
  validates :codename, presence: true
end
