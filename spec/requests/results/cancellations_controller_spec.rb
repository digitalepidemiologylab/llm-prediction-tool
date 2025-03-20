# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Results::CancellationsController, type: :request) do
  it { expect(described_class).to be < AuthenticatedBaseController }

  describe "#create" do
    let(:result) { create(:result) }
    let(:service) { Results::CancelService.new(result:) }

    before do
      sign_in(result.experiment.dataset.user)
      allow(Results::CancelService).to receive(:new).and_return(service)
      allow(service).to receive(:call).and_return(call_value)
    end

    context "when cancellation does NOT succeed" do
      let(:call_value) { false }

      it do
        post result_cancellations_path(result)
        expect(response).to redirect_to(experiment_path(result.experiment))
        expect(flash[:notice]).to be_nil
        expect(flash[:alert]).to match("Failed")
      end
    end

    context "when cancellation succeeds" do
      let(:call_value) { true }

      it do
        post result_cancellations_path(result)
        expect(response).to redirect_to(experiment_path(result.experiment))
        expect(flash[:notice]).to match("successfully")
        expect(flash[:alert]).to be_nil
      end
    end
  end
end
