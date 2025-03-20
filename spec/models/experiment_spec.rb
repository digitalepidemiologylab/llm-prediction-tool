# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Experiment, type: :model) do
  describe "Associations" do
    subject(:experiment) { build(:experiment) }

    it do
      expect(experiment).to belong_to(:dataset).inverse_of(:experiments)
      expect(experiment).to belong_to(:llm).inverse_of(:experiments)
      expect(experiment).to have_many(:results).inverse_of(:experiment).dependent(:destroy)
    end
  end

  describe "Validations" do
    describe "#llm_allowed" do
      context "when llm is hosted (default)" do
        subject(:experiment) { build(:experiment) }

        it do
          expect(experiment).to be_valid
          expect(experiment).to validate_presence_of(:system_prompt)
        end
      end

      context "when llm is dedicated BUT dataset user is different" do
        subject(:experiment) { build(:experiment, llm:) }

        let(:llm) { create(:llm, :dedicated) }

        it do
          expect(experiment).not_to be_valid
          expect(experiment.errors.full_messages).to include("LLM must be either hosted or deployed by Dataset's User")
        end
      end

      context "when llm is dedicated and dataset user matches" do
        subject(:experiment) { build(:experiment, dataset:, llm:) }

        let(:dataset) { create(:dataset) }
        let(:llm) { create(:llm, deployed_by_user: dataset.user) }

        it { expect(experiment).to be_valid }
      end
    end
  end
end
