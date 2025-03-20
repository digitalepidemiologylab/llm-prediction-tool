# frozen_string_literal: true

FactoryBot.define do
  factory :experiment do
    dataset
    llm

    system_prompt { "You are a helpful assistant. Provide a JSON response." }
  end
end
