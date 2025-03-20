# frozen_string_literal: true

class CreateDatasets < ActiveRecord::Migration[8.0]
  def change
    create_table :datasets, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false

      t.timestamps
    end
  end
end
