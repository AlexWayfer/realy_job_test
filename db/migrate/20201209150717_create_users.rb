# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.st_point :location, geographic: true
      t.string :phone_number
      t.datetime :last_visit

      t.timestamps
    end
  end
end
