# frozen_string_literal: true

FactoryBot.define do
  factory :llm do
    transient do
      simple_name { Faker::App.name }
    end

    provider { "openai" }
    sequence(:name) { |n| "#{simple_name} v#{n}" }
    codename { simple_name.downcase.gsub(/\s+/, "_") }

    trait :dedicated do
      association :deployed_by_user, factory: :user
    end
  end
end
