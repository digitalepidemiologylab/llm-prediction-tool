# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Openai::ChatAdapter, type: :adapter) do
  subject(:adapter) { described_class.new(experiment:, user_messages:) }

  let(:experiment) { create(:experiment) }

  before { experiment.update!(system_prompt:) }

  describe "#create" do
    before do
      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .to_return do |request|
          body = JSON.parse(request.body)
          provided_system_prompt = body.dig("messages", 0, "content", 0, "text")
          if provided_system_prompt.include?("JSON")
            {status: 200, headers: {"Content-Type" => "application/json"}, body: file_fixture("webmock/openai/chat_completion_success.json").read}
          else
            {status: 400, headers: {"Content-Type" => "application/json"}, body: file_fixture("webmock/openai/chat_completion_fail_bad_system_prompt.json").read}
          end
        end
    end

    context "when user_messages are text-only" do
      let(:user_messages) { [{role: :user, content: [{type: :text, text: "Openai::ChatAdapter test"}]}] }

      context "when the system prompt is not valid" do
        let(:system_prompt) { "Bad prompt." }

        it { expect(adapter.create[:code]).to eq(400) }
      end

      context "when the system prompt is valid" do
        let(:system_prompt) { "You are a helpful assistant. Provide a JSON response." }

        it { expect(adapter.create[:code]).to eq(200) }
      end
    end

    context "when user_messages contain an image" do
      let(:user_messages) { [{role: :user, content: [{type: :image_url, image_url: {detail: :high, url: "https://example.com/example.jpg"}}]}] }

      context "when the request is nominal" do
        let(:system_prompt) { "You are a helpful assistant. Provide a JSON response." }

        it { expect(adapter.create[:code]).to eq(200) }
      end
    end
  end
end
