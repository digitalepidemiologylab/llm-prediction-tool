# frozen_string_literal: true

require "rails_helper"

RSpec.describe(HasHttpBasicAuth, type: :request) do
  before do
    stub_const("MocksController", Class.new(ActionController::Base) do # rubocop:disable Rails/ApplicationController
      include HasHttpBasicAuth # Note: `described_class` is not available in this context

      def index
        render plain: "OK"
      end
    end)
  end

  around do |example|
    Rails.application.routes.draw do
      resources :mocks, only: :index
    end
    example.run
    Rails.application.reload_routes!
  end

  context "when NOT in production environment" do
    it "allows access without authentication" do
      get "/mocks"
      expect(response).to have_http_status(:success)
    end
  end

  context "when in production environment" do
    let(:username) { "user" }
    let(:password) { "pass" }

    before do
      allow(Rails.env).to receive(:production?).and_return(true)
    end

    around do |example|
      ENV["BASIC_AUTH_USERNAME"] = username
      ENV["BASIC_AUTH_PASSWORD"] = password
      example.run
      ENV.delete("BASIC_AUTH_USERNAME")
      ENV.delete("BASIC_AUTH_PASSWORD")
    end

    context "when credentials are MISSING" do
      it do
        get "/mocks", headers: {}
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when credentials are WRONG" do
      let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials("wrong_user", "wrong_pass") }

      it do
        get "/mocks", headers: {"HTTP_AUTHORIZATION" => credentials}
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when credentials are valid" do
      let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }

      it do
        get "/mocks", headers: {"HTTP_AUTHORIZATION" => credentials}
        expect(response).to have_http_status(:success)
      end
    end
  end
end
