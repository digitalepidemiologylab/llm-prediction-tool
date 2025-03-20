# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Results::CancelService, type: :service) do
  subject(:service) { described_class.new(result:) }

  let(:result) { create(:result) }

  context "when the result does NOT allow cancellation" do
    let(:error) { AASM::InvalidTransition.new(result, :cancel, :default) }

    before { allow(result).to receive(:cancel!).and_raise(error) }

    it { expect(service.call).to be_falsey }
  end

  context "when the result allows cancellation" do
    before { allow(result).to receive(:cancel!).and_return(true) }

    it { expect(service.call).to be_truthy }
  end
end
