# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Datasets::ExperimentsController, type: :request) do
  it { expect(described_class).to be < AuthenticatedBaseController }

  describe "#new" do
    let(:dataset) { create(:dataset) }

    before { sign_in(dataset.user) }

    it do
      get new_dataset_experiment_path(dataset)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    let(:dataset) { create(:dataset) }

    before { sign_in(dataset.user) }

    context "when params are NOT valid" do
      it do
        expect { post dataset_experiments_path(dataset, params: {experiment: {llm_id: "", system_prompt: ""}}) }
          .to not_change(Experiment, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:notice]).to be_nil
        expect(flash.now[:alert]).to eq("Failed to create experiment.")
      end
    end

    context "when params are nominal" do
      let(:llm) { create(:llm) }

      it do
        expect { post dataset_experiments_path(dataset, params: {experiment: {llm_id: llm.id, system_prompt: "test prompt"}}) }
          .to change(Experiment, :count).by(1)
        expect(response).to redirect_to(dataset_path(dataset))
        expect(flash[:notice]).to eq("Experiment was successfully created.")
        expect(flash.now[:alert]).to be_nil
      end
    end
  end
end
