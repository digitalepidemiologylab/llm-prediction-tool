# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Results::ProcessRowJob, type: :job) do
  subject(:job) { described_class.new(result:, index:) }

  let(:result) { create(:result) }
  let(:service) { instance_double(Results::SaveService) }

  before { allow(Results::SaveService).to receive(:new).and_return(service) }

  context "when the service succeeds" do
    before { allow(service).to receive(:call) }

    context "when result is initial" do
      let(:index) { 0 }

      it do
        expect { job.perform_now; result.reload }
          .to change(result, :status).from("initial").to("processing")
          .and(have_enqueued_job(described_class).with(result:, index: 1))
        expect(service).to have_received(:call)
          .with(index: 0, user_messages: [{role: :user, content: [{type: :text, text: "Hello"}]}])
      end
    end

    context "when result is processing" do
      before { result.process! }

      context "when the index is valid" do
        let(:index) { 1 }

        it do
          expect { job.perform_now; result.reload }
            .to not_change(result, :status).from("processing")
            .and(have_enqueued_job(described_class).with(result:, index: 2))
          expect(service).to have_received(:call)
            .with(index: 1, user_messages: [{role: :user, content: [{type: :text, text: "Test"}]}])
        end
      end

      context "when the index is past end" do
        let(:index) { 2 }

        it do
          expect { job.perform_now; result.reload }
            .to change(result, :status).from("processing").to("ready")
            .and(not_have_enqueued_job(described_class))
          expect(service).not_to have_received(:call)
        end
      end
    end
  end

  context "when the service fails temporarily" do
    let(:index) { 0 }

    before { allow(service).to receive(:call).and_raise(Results::SaveService::TemporaryError) }

    it do
      expect { job.perform_now; result.reload }
        .to not_raise_error
        .and(change(result, :status).from("initial").to("processing"))
        .and(have_enqueued_job(described_class).with(result:, index:))
      # automatically retries
    end
  end

  context "when the service fails unrecoverably" do
    let(:index) { 0 }

    before { allow(service).to receive(:call).and_raise(Results::SaveService::UnrecoverableError) }

    it do
      expect { job.perform_now; result.reload }
        .to not_raise_error
        .and(change(result, :status).from("initial").to("failed"))
        .and(not_have_enqueued_job(described_class))
    end
  end
end
