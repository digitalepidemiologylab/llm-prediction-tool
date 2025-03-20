# frozen_string_literal: true

class AddLlmCredentialsJsonToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :llm_credentials_json, :jsonb
  end
end
