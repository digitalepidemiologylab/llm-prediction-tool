# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ApplicationController, type: :request) do
  describe "Concerns" do
    it do
      expect(described_class.ancestors).to include(HasHttpBasicAuth)
      expect(described_class.ancestors).to include(HasPunditAuth)
    end
  end

  describe "Rescues" do
    let(:controller) { HomeController.new }

    before do
      allow(HomeController).to receive(:new).and_return(controller)
      allow(Sentry).to receive(:capture_exception)
    end

    context "when NO exception occurs" do
      before { allow(controller).to receive(:index) }

      it do
        expect { get root_path }.not_to raise_error
        expect(controller).to have_received(:index)
        expect(Sentry).not_to have_received(:capture_exception)
      end
    end

    context "when an UNHANDLED exception occurs" do
      let(:error) { StandardError.new("problem in controller action") }

      before { allow(controller).to receive(:index).and_raise(error) }

      it do
        expect { get root_path }.to raise_error(error)
        expect(controller).to have_received(:index)
        expect(Sentry).to have_received(:capture_exception)
      end
    end
  end
end
