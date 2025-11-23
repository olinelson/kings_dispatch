class CreateXInterestXTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :x_interest_x_topics do |t|
      t.references :x_interest, null: false, foreign_key: true
      t.references :x_topic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
