# frozen_string_literal: true

class CreateLlms < ActiveRecord::Migration[7.2]
  def change
    create_enum(:provider, %w[anthropic azure openai])

    create_table :llms, id: :uuid do |t|
      t.enum :provider, enum_type: :provider, null: false
      t.string :name, null: false
      t.jsonb :data, null: false, default: {}
      t.timestamp :deprecated_at, index: {where: "deprecated_at IS NULL"}

      t.timestamps
    end
  end
end
