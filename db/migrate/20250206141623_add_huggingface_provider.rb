# frozen_string_literal: true

class AddHuggingfaceProvider < ActiveRecord::Migration[8.0]
  def change
    enum_name = "provider"
    enum_value = "huggingface"

    reversible do |dir|
      dir.up do
        add_enum_value enum_name, enum_value
      end

      dir.down do
        safety_assured do
          execute <<~SQL.squish
            DELETE FROM results USING experiments, llms
              WHERE results.experiment_id = experiments.id
              AND experiments.llm_id = llms.id
              AND llms."#{enum_name}" = '#{enum_value}';
            DELETE FROM experiments USING llms
              WHERE experiments.llm_id = llms.id
              AND llms."#{enum_name}" = '#{enum_value}';
            DELETE FROM llms WHERE "#{enum_name}" = '#{enum_value}';
            DELETE FROM pg_enum WHERE enumlabel = '#{enum_value}' AND enumtypid IN (
              SELECT t.oid
              FROM pg_type t
              INNER JOIN pg_namespace n ON n.oid = t.typnamespace
              WHERE t.typname = '#{enum_name}'
              AND n.nspname = ANY(current_schemas(true))
            );
          SQL
        end
      end
    end
  end
end
