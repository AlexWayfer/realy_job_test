# frozen_string_literal: true

class CreateUserSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :user_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.int4range :age_preference
      t.float :max_distance

      t.timestamps
    end
  end
end
