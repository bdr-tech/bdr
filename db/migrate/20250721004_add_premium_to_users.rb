class AddPremiumToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :is_premium, :boolean, default: false
    add_column :users, :premium_expires_at, :datetime
    add_column :users, :premium_type, :string # monthly, yearly, lifetime

    add_index :users, :is_premium
    add_index :users, :premium_expires_at
  end
end
