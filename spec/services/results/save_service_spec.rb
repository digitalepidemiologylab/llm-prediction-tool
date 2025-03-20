# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Results::SaveService, type: :service) do
  subject(:service) { described_class.new(result:) }

  let(:provider) { "openai" }
  let(:llm) { create(:llm, provider:) }
  let(:experiment) { create(:experiment, llm:) }
  let(:result) { create(:result, experiment:) }
  let(:index) { 123 }
  let(:user_messages) { [{role: :user, content: [{type: :text, text: "ResultIdxService test"}]}] }

  context "when the provider is openai" do
    let(:adapter) { instance_double(Openai::ChatAdapter) }
    let(:response) { {code:, success:, error:} }

    before do
      allow(Openai::ChatAdapter).to receive(:new).and_return(adapter)
      allow(adapter).to receive(:create).and_return(response)
    end

    context "when the API call is successful" do
      let(:code) { 200 }
      let(:success) { JSON.parse(file_fixture("webmock/openai/chat_completion_success.json").read).dig("choices", 0, "message", "content") }
      let(:error) { nil }

      it do
        expect { service.call(index:, user_messages:); result.reload }
          .to not_raise_error
          .and(not_change { result.data.dig("error", "message") }.from(nil))
          .and(change { result.data.dig("annotations", "123") }.from(nil).to(
            %({\n  "response": "Hello! How can I assist you today?"\n})
          ))
      end
    end

    context "when the API response requires we SKIP the row" do
      let(:code) { 500 }
      let(:success) { nil }
      let(:error) { "The model produced invalid content." }

      before { response[:skip] = true }

      it do
        expect { service.call(index:, user_messages:); result.reload }
          .to not_raise_error
          .and(not_change { result.data.dig("error", "message") }.from(nil))
          .and(not_change { result.data.dig("annotations", "123") }.from(nil))
          .and(change { result.data.dig("skipped") }.from(nil).to([123]))
      end
    end

    context "when the API is down" do
      let(:code) { 503 }
      let(:success) { nil }
      let(:error) { "Maintenance" }

      it do
        expect { service.call(index:, user_messages:); result.reload }
          .to raise_error(described_class::TemporaryError)
          .and(not_change { result.data.dig("error", "message") }.from(nil))
          .and(not_change { result.data.dig("annotations", "123") }.from(nil))
      end
    end

    context "when the API call fails" do
      let(:code) { 401 }
      let(:success) { nil }
      let(:error) { JSON.parse(file_fixture("webmock/openai/chat_completion_fail_bad_auth.json").read).dig("error", "message") }

      it do
        expect { service.call(index:, user_messages:); result.reload }
          .to raise_error(described_class::UnrecoverableError)
          .and(change { result.data.dig("error", "message") }.from(nil))
          .and(not_change { result.data.dig("annotations", "123") }.from(nil))
      end
    end
  end

  context "when the provider is gemini" do
    let(:provider) { "gemini" }
    let(:adapter) { instance_double(Gemini::ChatAdapter) }
    let(:response) { {code: 200, success: {}} }

    before do
      allow(Gemini::ChatAdapter).to receive(:new).and_return(adapter)
      allow(adapter).to receive(:create).and_return(response)
    end

    it { expect(service.call(index:, user_messages:)).to be_truthy }
  end

  context "when the provider is anthropic" do
    let(:provider) { "anthropic" }
    let(:adapter) { instance_double(Anthropic::ChatAdapter) }
    let(:response) { {code: 200, success: {}} }

    before do
      allow(Anthropic::ChatAdapter).to receive(:new).and_return(adapter)
      allow(adapter).to receive(:create).and_return(response)
    end

    it { expect(service.call(index:, user_messages:)).to be_truthy }
  end

  context "when the provider is huggingface" do
    let(:provider) { "huggingface" }
    let(:adapter) { instance_double(Huggingface::ChatAdapter) }
    let(:response) { {code: 200, success: {}} }

    before do
      allow(Huggingface::ChatAdapter).to receive(:new).and_return(adapter)
      allow(adapter).to receive(:create).and_return(response)
    end

    it { expect(service.call(index:, user_messages:)).to be_truthy }
  end

  context "when the provider NOT supported" do
    before do
      allow(llm).to receive(:provider).and_return("WRONG")
    end

    it do
      expect { service.call(index:, user_messages:) }
        .to raise_error(described_class::UnrecoverableError, "LLM provider WRONG not supported")
    end
  end

  context "when the adapter raises an error" do
    before do
      allow(Openai::ChatAdapter).to receive(:new).and_raise(StandardError, "Test error")
    end

    it do
      expect { service.call(index:, user_messages:) }
        .to raise_error(described_class::UnrecoverableError, "Test error")
    end
  end
end
