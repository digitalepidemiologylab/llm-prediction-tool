# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Experiments::ResultsController, type: :request) do
  it { expect(described_class).to be < AuthenticatedBaseController }

  describe "#create" do
    let(:experiment) { create(:experiment) }

    before { sign_in(experiment.dataset.user) }

    context "when new result is NOT possible" do
      before do
        allow(Experiment).to receive(:find).with(experiment.id).and_return(experiment)
        allow(experiment).to receive(:results).and_return(
          instance_double(ActiveRecord::Relation, new: instance_double(Result, save: false))
        )
      end

      it do
        expect { post experiment_results_path(experiment) }
          .to not_change(Result, :count)
          .and(not_have_enqueued_job(Results::ProcessRowJob))
        expect(response).to redirect_to(experiment_path(experiment))
        expect(flash[:notice]).to be_nil
        expect(flash[:alert]).to eq("Failed to create result.")
      end
    end

    context "when new result is possible" do
      it do
        expect { post experiment_results_path(experiment) }
          .to change(Result, :count).by(1)
          .and(have_enqueued_job(Results::ProcessRowJob))
        expect(response).to redirect_to(experiment_path(experiment))
        expect(flash[:notice]).to match(/Result.*successfully created/)
        expect(flash[:alert]).to be_nil
      end
    end
  end
end
