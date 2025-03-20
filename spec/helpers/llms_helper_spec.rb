# frozen_string_literal: true

require "rails_helper"

RSpec.describe(LlmsHelper, type: :helper) do
  describe "#provider_name" do
    context "when the provider is NOT supported" do
      it { expect(helper.provider_name("unknown_provider")).to eq("Unknown Provider") }
    end

    context "when the provider is supported" do
      it { expect(helper.provider_name("openai")).to eq("OpenAI") }
    end
  end
end
