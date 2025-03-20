# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Llm, type: :model) do
  describe "Associations" do
    subject(:llm) { build(:llm) }

    it do
      expect(llm).to belong_to(:deployed_by_user).class_name("User").optional.inverse_of(:deployed_llms)
      expect(llm).to have_many(:experiments).inverse_of(:llm).dependent(:restrict_with_error)
    end
  end

  describe "Validations" do
    subject(:llm) { build(:llm) }

    it { expect(llm).to be_valid }

    describe "codename" do
      it { expect(llm).to validate_presence_of(:codename) }
    end

    describe "name" do
      it { expect(llm).to validate_presence_of(:name) }
    end

    describe "provider" do
      it { expect(llm).to validate_presence_of(:provider) }
    end
  end
end
