# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ExperimentPolicy, type: :policy) do
  let!(:alice_experiment) { create(:experiment) }
  let!(:bob_experiment) { create(:experiment) }

  let(:alice) { alice_experiment.dataset.user }
  let(:bob) { bob_experiment.dataset.user }

  permissions :show?, :create?, :edit?, :update? do
    it do
      expect(described_class).to permit(alice, alice_experiment)
      expect(described_class).to permit(bob, bob_experiment)

      expect(described_class).not_to permit(alice, bob_experiment)
      expect(described_class).not_to permit(bob, alice_experiment)
    end
  end

  describe ExperimentPolicy::Scope do
    describe "#resolve" do
      it do
        expect(described_class.new(alice, Experiment).resolve).to contain_exactly(alice_experiment)
        expect(described_class.new(bob, Experiment).resolve).to contain_exactly(bob_experiment)
      end
    end
  end
end
