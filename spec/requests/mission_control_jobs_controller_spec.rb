# frozen_string_literal: true

require "rails_helper"

RSpec.describe(MissionControlJobsController, type: :request) do
  before do
    stub_const("McjsController", Class.new(described_class) do
      def index
        render plain: "OK"
      end
    end)
  end

  around do |example|
    Rails.application.routes.draw do
      resources :mcjs, only: :index
    end
    example.run
    Rails.application.reload_routes!
  end

  context "when accessed by a user who is NOT authenticated" do
    it { expect { get "/mcjs" }.to raise_error(Pundit::NotAuthorizedError) }
  end

  context "when accessed by an authenticated user who is NOT an admin" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it { expect { get "/mcjs" }.to raise_error(Pundit::NotAuthorizedError) }
  end

  context "when accessed by an admin" do
    let(:user) { create(:user, admin: true) }

    before { sign_in(user) }

    it do
      get "/mcjs"
      expect(response).to have_http_status(:success)
    end
  end
end
