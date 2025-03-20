# frozen_string_literal: true

class AddLlmParameters < ActiveRecord::Migration[8.0]
  def change
    add_column :llms, :codename, :string, null: false, default: "" # temp default
    add_column :llms, :parameters, :jsonb, null: false, default: {}

    reversible do |dir|
      dir.up do
        safety_assured do
          execute <<~SQL.squish
            UPDATE llms
            SET codename = data->>'model',
                parameters = data->'parameters',
                data = data - 'model' - 'parameters';
          SQL
        end

        change_column_default :llms, :codename, nil
      end

      dir.down do
        safety_assured do
          execute <<~SQL.squish
            UPDATE llms
            SET data = data || jsonb_build_object(
              'model', codename,
              'parameters', parameters
            )
          SQL
        end
      end
    end
  end
end
