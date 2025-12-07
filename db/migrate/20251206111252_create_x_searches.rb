class CreateXSearches < ActiveRecord::Migration[8.1]
  def change
    create_table :x_searches do |t|
      t.references :x_topic, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
