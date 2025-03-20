# frozen_string_literal: true

class AddCancelledToResultstatus < ActiveRecord::Migration[8.0]
  def up
    add_enum_value :result_status, "cancelled"
  end

  # See https://github.com/bibendi/activerecord-postgres_enum/blob/134a09f281d1956bc6ca537a36f84c369d324b1a/lib/active_record/postgres_enum/postgresql_adapter.rb#L60-L71
  def down
    safety_assured do
      enum_type = quote("result_status")
      enum_value = quote("cancelled")
      execute <<~SQL.squish
        UPDATE results SET status = 'failed' WHERE status = #{enum_value};
        DELETE FROM pg_enum WHERE enumlabel = #{enum_value} AND enumtypid IN (
          SELECT t.oid
          FROM pg_type t
          INNER JOIN pg_namespace n ON n.oid = t.typnamespace
          WHERE t.typname = #{enum_type}
          AND n.nspname = ANY(current_schemas(true))
        );
      SQL
    end
  end
end
