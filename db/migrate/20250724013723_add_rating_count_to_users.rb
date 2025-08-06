class AddRatingCountToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :rating_count, :integer, default: 0
    add_index :users, :rating_count
  end
end
