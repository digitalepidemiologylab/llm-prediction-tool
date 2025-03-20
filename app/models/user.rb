# frozen_string_literal: true

class User < ApplicationRecord
  self.implicit_order_column = :created_at

  has_many :datasets, inverse_of: :user, dependent: :destroy
  has_many :deployed_llms, class_name: "Llm", inverse_of: :deployed_by_user, dependent: :destroy

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable

  encrypts :llm_credentials_json

  before_save :serialize_latest_llm_credentials

  def llm_credentials=(value)
    @llm_credentials = value
    serialize_latest_llm_credentials
  end

  def llm_credentials
    @llm_credentials ||= JSON.parse(llm_credentials_json || "{}").deep_symbolize_keys
  end

  private def serialize_latest_llm_credentials
    self.llm_credentials_json = @llm_credentials.nil? ? nil : @llm_credentials.to_json
  end
end
