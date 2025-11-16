class AddQueriesToXTopics < ActiveRecord::Migration[8.1]
  def change
    add_column :x_topics, :queries, :json
  end
end
