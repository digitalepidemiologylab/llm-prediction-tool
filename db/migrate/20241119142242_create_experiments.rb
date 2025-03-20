# frozen_string_literal: true

class CreateExperiments < ActiveRecord::Migration[8.0]
  def change
    create_table :experiments, id: :uuid do |t|
      t.references :dataset, null: false, foreign_key: true, type: :uuid
      t.references :llm, null: false, foreign_key: true, type: :uuid
      t.string :system_prompt, null: false

      t.timestamps
    end
  end
end
