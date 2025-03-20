# frozen_string_literal: true

FactoryBot.define do
  factory :result do
    experiment

    trait :with_data_row do
      after(:build) do |result|
        result.data["annotations"] = {"0" => %({"foo": "bar"})}
      end
    end

    trait :failed do
      after(:build) do |result|
        result.process
        result.fail
        result.data["error"] = {"message" => "Oops"}
      end
    end

    trait :ready do
      after(:build) do |result|
        result.process
        result.complete
      end
    end
  end
end
