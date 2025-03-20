# frozen_string_literal: true

require "rails_helper"

RSpec.describe(HomeController, type: :request) do
  describe "#index" do
    context "when anonymous visitor" do
      it do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated user" do
      let(:user) { create(:user) }

      before { sign_in(user) }

      it do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
