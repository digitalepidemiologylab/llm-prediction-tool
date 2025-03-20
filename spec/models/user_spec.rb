# frozen_string_literal: true

require "rails_helper"

RSpec.describe(User, type: :model) do
  describe "Associations" do
    subject(:user) { build(:user) }

    it do
      expect(user).to have_many(:datasets).inverse_of(:user).dependent(:destroy)
      expect(user).to have_many(:deployed_llms).class_name("Llm").inverse_of(:deployed_by_user).dependent(:destroy)
    end
  end

  describe "Validations" do
    subject(:user) { build(:user) }

    it { expect(user).to be_valid }

    describe "email" do
      before { create(:user) } # create one, to test uniqueness

      it do
        expect(user).to validate_presence_of(:email)
        expect(user).to validate_uniqueness_of(:email).case_insensitive
      end
    end
  end

  describe "Callbacks" do
    describe "serialize_latest_llm_credentials" do
      subject(:user) { create(:user, llm_credentials: {x: "y"}) }

      before { user.llm_credentials[:test] = 5 }

      it { expect { user.save! }.to change(user, :llm_credentials_json).to(%({"x":"y","test":5})) }
    end
  end

  describe "llm_credentials=" do
    subject(:user) { build(:user, :with_anthropic_credentials) }

    context "when argument is a hash" do
      it do
        expect { user.llm_credentials = {x: "y"} }
          .to change(user, :llm_credentials).to({x: "y"})
          .and(change(user, :llm_credentials_json).to(%({"x":"y"})))
      end
    end

    context "when argument is nil" do
      it do
        expect { user.llm_credentials = nil }
          .to change(user, :llm_credentials).to({})
          .and(change(user, :llm_credentials_json).to(nil))
      end
    end
  end

  describe "llm_credentials" do
    context "when value is a hash" do
      subject(:user) { create(:user, llm_credentials: {x: "y"}) }

      it do
        expect(user.llm_credentials).to eq({x: "y"})
        expect(user.llm_credentials_json).to eq(%({"x":"y"}))
      end
    end

    context "when argument is nil" do
      subject(:user) { create(:user) }

      it do
        expect(user.llm_credentials).to eq({})
        expect(user.llm_credentials_json).to be_nil
      end
    end
  end
end
