class AddIsHostToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_host, :boolean, default: false, null: false
    add_index :users, :is_host
  end
end
