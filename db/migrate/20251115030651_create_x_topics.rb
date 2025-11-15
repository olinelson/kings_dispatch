class CreateXTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :x_topics do |t|
      t.string :title
      t.string :description
      t.string :query

      t.timestamps
    end
  end
end
