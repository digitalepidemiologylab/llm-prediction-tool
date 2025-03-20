# frozen_string_literal: true

require "rails_helper"

RSpec.describe(DatasetsController, type: :request) do
  it { expect(described_class).to be < AuthenticatedBaseController }

  describe "#index" do
    let(:user) { create(:user) }
    let!(:datasets) { create_list(:dataset, 2, user:) }
    let!(:other_datasets) { create_list(:dataset, 2) }

    before { sign_in(user) }

    it do
      get datasets_path
      expect(response).to have_http_status(:success)
      datasets.each { expect(response.body).to include(_1.id.to_s) }
      other_datasets.each { expect(response.body).not_to include(_1.id.to_s) }
    end
  end

  describe "#show" do
    let(:dataset) { create(:dataset) }

    before { sign_in(dataset.user) }

    it do
      get dataset_path(dataset)
      expect(response).to have_http_status(:success)
    end
  end

  describe "#new" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it do
      get new_dataset_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    context "when params are NOT valid" do
      it do
        post datasets_path, params: {dataset: {name: "", evaluation: ""}}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when params are nominal" do
      let(:file) do
        fixture_file_upload(
          Rails.root.join("spec/fixtures/files/sample_dataset_text.csv"),
          "text/csv"
        )
      end

      it do
        post datasets_path, params: {dataset: {name: "test name", evaluation: file}}
        expect(response).to redirect_to(dataset_path(Dataset.last))
      end
    end
  end
end
