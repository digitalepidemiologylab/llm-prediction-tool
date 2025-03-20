# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ResultPolicy, type: :policy) do
  let!(:alice_result) { create(:result) }
  let!(:bob_result) { create(:result) }

  let(:alice) { alice_result.experiment.dataset.user }
  let(:bob) { bob_result.experiment.dataset.user }

  permissions :show?, :edit? do
    it do
      expect(described_class).to permit(alice, alice_result)
      expect(described_class).to permit(bob, bob_result)

      expect(described_class).not_to permit(alice, bob_result)
      expect(described_class).not_to permit(bob, alice_result)
    end
  end

  describe ResultPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(alice, Result).resolve).to contain_exactly(alice_result)
        expect(described_class.new(bob, Result).resolve).to contain_exactly(bob_result)
      end
    end
  end
end
