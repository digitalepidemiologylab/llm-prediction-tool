# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Result, type: :model) do
  describe "Associations" do
    subject(:result) { build(:result) }

    it { expect(result).to belong_to(:experiment).inverse_of(:results) }
  end

  describe "Validations" do
    subject(:result) { build(:result) }

    it { expect(result).to be_valid }
  end

  describe "#final?" do
    context "when the status is initial" do
      subject(:result) { build(:result) }

      it { expect(result).not_to be_final }
    end

    context "when the status is failed" do
      subject(:result) { build(:result, :failed) }

      it { expect(result).to be_final }
    end

    context "when the status is ready" do
      subject(:result) { build(:result, :ready) }

      it { expect(result).to be_final }
    end
  end
end
