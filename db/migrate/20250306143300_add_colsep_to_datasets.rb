# frozen_string_literal: true

class AddColsepToDatasets < ActiveRecord::Migration[8.0]
  def change
    add_column :datasets, :column_separator, :string, limit: 1, default: ",", null: false
  end
end
