class CreateXPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :x_posts do |t|
      t.string :type
      t.string :external_id
      t.json :data
      t.references :x_search, null: false, foreign_key: true

      t.timestamps
    end
  end
end
