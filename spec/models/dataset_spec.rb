# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Dataset, type: :model) do
  describe "Associations" do
    subject(:dataset) { build(:dataset) }

    it do
      expect(dataset).to belong_to(:user).inverse_of(:datasets)
      expect(dataset).to have_many(:experiments).inverse_of(:dataset).dependent(:destroy)
      expect(dataset).to have_one_attached(:evaluation)
    end
  end

  describe "Validations" do
    subject(:dataset) { build(:dataset) }

    it { expect(dataset).to be_valid }

    describe "name" do
      it { expect(dataset).to validate_presence_of(:name) }
    end

    describe "column_separator" do
      it { expect(dataset).to validate_presence_of(:column_separator) }
      it { expect(dataset).to validate_length_of(:column_separator).is_equal_to(1) }
    end

    describe "dataset" do
      it { expect(dataset).to validate_presence_of(:evaluation) }

      context "when file is not a CSV" do
        before do
          dataset.evaluation.attach(
            io: StringIO.new("not a csv"),
            filename: "test.txt",
            content_type: "text/plain"
          )
        end

        it { expect(dataset).not_to be_valid }
      end
    end
  end
end
