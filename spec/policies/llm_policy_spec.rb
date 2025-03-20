# frozen_string_literal: true

require "rails_helper"

RSpec.describe(LlmPolicy, type: :policy) do
  let!(:alice_llm) { create(:llm, :dedicated) }
  let!(:bob_llm) { create(:llm, :dedicated) }
  let!(:public_llm) { create(:llm) }

  let(:alice) { alice_llm.deployed_by_user }
  let(:bob) { bob_llm.deployed_by_user }

  describe LlmPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(alice, Llm).resolve).to contain_exactly(alice_llm, public_llm)
        expect(described_class.new(bob, Llm).resolve).to contain_exactly(bob_llm, public_llm)
      end
    end
  end
end
