# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8, mix_case: true, special_characters: true) }
    confirmed_at { Time.zone.now }

    trait :with_anthropic_credentials do
      llm_credentials { {anthropic: {api_key: Random.hex[..6]}} }
    end

    trait :with_hf_credentials do
      llm_credentials { {huggingface: {token: Random.hex[..6]}} }
    end
  end
end
