class RemoveQueryFromXTopics < ActiveRecord::Migration[8.1]
  def change
    remove_column :x_topics, :query
  end
end
