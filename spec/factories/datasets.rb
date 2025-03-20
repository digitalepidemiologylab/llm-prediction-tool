# frozen_string_literal: true

FactoryBot.define do
  factory :dataset do
    transient do
      fixture_filename { "sample_dataset_text.csv" }
    end

    user

    sequence(:name) { |n| "Dataset #{n}" }

    after(:build) do |dataset, evaluator|
      io = Rails.root.join("spec/fixtures/files/#{evaluator.fixture_filename}").open("rb")
      dataset.evaluation.attach(
        io:,
        filename: evaluator.fixture_filename,
        content_type: "text/csv"
      )
    end

    trait :with_image do
      transient do
        fixture_filename { "sample_dataset_image.csv" }
      end
    end
  end
end
