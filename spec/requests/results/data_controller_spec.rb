# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Results::DataController, type: :request) do
  it { expect(described_class).to be < AuthenticatedBaseController }

  describe "#show" do
    before { sign_in(result.experiment.dataset.user) }

    context "when Result is not downloadable" do
      let(:result) { create(:result) }

      it do
        expect { get result_data_path(result) }
          .to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when request is nominal" do
      let(:result) { create(:result, :ready, :with_data_row) }

      it do
        get result_data_path(result)
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json")
        expect(response.headers["Content-Disposition"]).to include("attachment")
      end
    end
  end
end
