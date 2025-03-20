# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Gemini::ChatAdapter, type: :adapter) do
  subject(:adapter) { described_class.new(experiment:, user_messages:) }

  let(:dataset) { create(:dataset, user:) }
  let(:llm) { create(:llm, :gemini) }
  let(:experiment) { create(:experiment, llm:, dataset:) }

  describe "#create" do
    before do
      stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{llm.codename}:generateContent")
        .with(query: hash_including("key"))
        .to_return do |request|
          if request.uri.query_values["key"].present?
            {status: 200, headers: {"Content-Type" => "application/json"}, body: file_fixture("webmock/gemini/text_generation_success.json").read}
          else
            {status: 403, headers: {"Content-Type" => "application/json"}, body: file_fixture("webmock/gemini/text_generation_fail_bad_auth.json").read}
          end
        end
    end

    context "when user_messages are text-only" do
      let(:user_messages) { [{role: :user, content: [{type: :text, text: "Gemini::ChatAdapter test"}]}] }

      context "when the User does NOT have a valid API key" do
        let(:user) { create(:user) }

        it do
          response = adapter.create
          expect(response[:code]).to eq(403)
          expect(response[:success]).to be_nil
          expect(response[:error]).to match("Please use API Key")
        end
      end

      context "when the request is nominal" do
        let(:user) { create(:user, llm_credentials: {gemini: {api_key: "abc"}}) }

        it do
          response = adapter.create
          expect(response[:code]).to eq(200)
          expect(response[:success]).to eq(%({"user_input": "Hello"}))
          expect(response[:error]).to be_nil
        end
      end
    end

    context "when user_messages contain an image" do
      let(:user_messages) { [{role: :user, content: [{type: :image_url, image_url: {detail: :high, url: "https://example.com/example.jpg"}}]}] }

      context "when the request is nominal" do
        let(:user) { create(:user, llm_credentials: {gemini: {api_key: "abc"}}) }

        it { expect { adapter.create }.to raise_error(NotImplementedError) }
      end
    end
  end
end
