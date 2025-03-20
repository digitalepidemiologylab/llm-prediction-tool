# frozen_string_literal: true

class AddCreatedatIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    %i[datasets experiments llms results users].each do |table|
      add_index table, :created_at, algorithm: :concurrently
    end
  end
end
