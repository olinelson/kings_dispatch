class CreateXPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :x_posts do |t|
      t.string :type
      t.string :external_id
      t.string :text
      t.integer :retweet_count
      t.integer :reply_count
      t.integer :like_count
      t.integer :quote_count
      t.integer :view_count
      t.boolean :is_blue_verified
      t.boolean :is_automated
      t.datetime :posted_at
      t.references :x_search, null: false, foreign_key: true

      t.timestamps
    end
  end
end
