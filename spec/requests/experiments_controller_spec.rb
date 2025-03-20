# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ExperimentsController, type: :request) do
  let(:user) { create(:user) }
  let(:dataset) { create(:dataset, user:) }
  let(:experiment) { create(:experiment, dataset:) }

  describe "#show" do
    context "when user is NOT authenticated" do
      it do
        get experiment_path(experiment)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated but NOT authorized" do
      let(:other_user) { create(:user) }

      before { sign_in(other_user) }

      it do
        expect { get experiment_path(experiment) }
          .to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when user is authenticated and authorized" do
      before { sign_in(user) }

      it do
        get experiment_path(experiment)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
