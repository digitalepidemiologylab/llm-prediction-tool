# frozen_string_literal: true

class CreateResults < ActiveRecord::Migration[8.0]
  def change
    create_enum(:result_status, %w[initial processing ready failed])

    create_table :results, id: :uuid do |t|
      t.references :experiment, null: false, foreign_key: true, type: :uuid
      t.enum(:status, enum_type: :result_status, null: false, default: "initial")
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
