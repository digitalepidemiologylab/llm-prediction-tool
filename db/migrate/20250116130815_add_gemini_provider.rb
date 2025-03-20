# frozen_string_literal: true

class AddGeminiProvider < ActiveRecord::Migration[8.0]
  def up
    add_enum_value :provider, "gemini"
  end

  # See https://github.com/bibendi/activerecord-postgres_enum/blob/134a09f281d1956bc6ca537a36f84c369d324b1a/lib/active_record/postgres_enum/postgresql_adapter.rb#L60-L71
  def down
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM llms WHERE provider = 'gemini';
        DELETE FROM pg_enum WHERE enumlabel = 'gemini' AND enumtypid IN (
          SELECT t.oid
          FROM pg_type t
          INNER JOIN pg_namespace n ON n.oid = t.typnamespace
          WHERE t.typname = 'provider'
          AND n.nspname = ANY(current_schemas(true))
        );
      SQL
    end
  end
end
