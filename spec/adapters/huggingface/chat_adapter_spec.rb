# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Huggingface::ChatAdapter, type: :adapter) do
  subject(:adapter) { described_class.new(experiment:, user_messages:) }

  let(:dataset) { create(:dataset, user:) }
  let(:llm) { create(:llm, :huggingface) }
  let(:experiment) { create(:experiment, llm:, dataset:) }

  describe "#create" do
    let(:api_response) do
      ->(request) do
        if request.headers["Authorization"].split[1].blank? # Key after word "Bearer"
          {status: 401, headers: {"Content-Type" => "application/json"}, body: file_fixture("webmock/huggingface/chat_completion_fail_bad_auth.json").read}
        elsif JSON.parse(request.body)["response_format"] == {"type" => "json"}
          {status: 422, headers: {"Content-Type" => "text/plain; charset=utf-8"}, body: file_fixture("webmock/huggingface/chat_completion_fail_incomplete_responseformat.txt").read}
        else
          {status: 200, headers: {"Content-Type" => "application/json"}, body: file_fixture("webmock/huggingface/chat_completion_success.json").read}
        end
      end
    end

    context "when user_messages are text-only" do
      let(:user_messages) { [{role: :user, content: [{type: :text, text: "Huggingface::ChatAdapter test"}]}] }

      context "when llm is serverless" do
        before do
          stub_request(:post, "https://api-inference.huggingface.co/models/#{llm.codename}/v1/chat/completions")
            .to_return { api_response.call(_1) }
        end

        context "when the User does NOT have a valid API key" do
          let(:user) { create(:user) }

          it do
            response = adapter.create
            expect(response[:code]).to eq(401)
            expect(response[:success]).to be_nil
            expect(response[:error]).to eq("401 Unauthorized")
          end
        end

        context "when the response_format specifies json with NO schema" do
          let(:user) { create(:user, :with_hf_credentials) }

          before { llm.update!(parameters: {"response_format" => {"type" => "json"}}) }

          it do
            response = adapter.create
            expect(response[:code]).to eq(422)
            expect(response[:success]).to be_nil
            expect(response[:error]).to match("missing field `value`")
          end
        end

        context "when the request is nominal" do
          let(:user) { create(:user, :with_hf_credentials) }

          it do
            response = adapter.create
            expect(response[:code]).to eq(200)
            expect(response[:success]).to end_with(%({"fr": "Bonjour"}))
            expect(response[:error]).to be_nil
          end
        end
      end

      context "when llm is hosted by a third party" do
        before do
          llm.update!(host: "fake_host")
          stub_request(:post, "https://router.huggingface.co/fake_host/v1/chat/completions")
            .to_return { api_response.call(_1) }
        end

        context "when the request is nominal" do
          let(:user) { create(:user, :with_hf_credentials) }

          it do
            response = adapter.create
            expect(response[:code]).to eq(200)
            expect(response[:success]).to end_with(%({"fr": "Bonjour"}))
            expect(response[:error]).to be_nil
          end
        end
      end

      context "when llm is deployed by a user" do
        let(:user) { create(:user, :with_hf_credentials) }

        before { llm.update!(deployed_by_user: user, host: "fake_host") }

        context "when the endpoint is SCALED TO ZERO and then warms up" do
          before do
            stub_request(:post, "https://fake_host.endpoints.huggingface.cloud/v1/chat/completions")
              .to_return { {status: 503, headers: {"Content-Type" => "application/json"}, body: file_fixture("webmock/huggingface/chat_completion_fail_model_cold.json").read} }
              .to_return { api_response.call(_1) }
          end

          it do
            # first call fails
            response = adapter.create
            expect(response[:code]).to eq(503)
            expect(response[:success]).to be_nil
            expect(response[:error]).to eq("503 Service Unavailable")
            # subsequent call (retrying ~10 minutes later) succeeds
            response = adapter.create
            expect(response[:code]).to eq(200)
            expect(response[:success]).to end_with(%({"fr": "Bonjour"}))
            expect(response[:error]).to be_nil
          end
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
