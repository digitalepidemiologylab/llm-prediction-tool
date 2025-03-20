# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    enable_extension "citext"

    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.citext :email, null: false
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.citext :unconfirmed_email

      t.timestamps

      t.index :email, unique: true
      t.index :reset_password_token, unique: true
      t.index :confirmation_token, unique: true
    end
  end
end
