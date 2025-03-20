# frozen_string_literal: true

class AddDeploymentToLlms < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      add_reference :llms, :deployed_by_user, foreign_key: {to_table: :users}, type: :uuid
    end
    add_column :llms, :host, :string
  end
end
