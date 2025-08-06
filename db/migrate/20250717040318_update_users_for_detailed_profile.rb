class UpdateUsersForDetailedProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :nickname, :string
    add_column :users, :real_name, :string
    add_column :users, :height, :integer
    add_column :users, :weight, :integer
    add_column :users, :positions, :text
    add_column :users, :city, :string
    add_column :users, :district, :string
    add_column :users, :team_name, :string
    add_column :users, :bio, :text
    add_column :users, :profile_completed, :boolean, default: false

    rename_column :users, :position, :old_position
    rename_column :users, :skill_level, :old_skill_level
    rename_column :users, :location, :old_location

    add_index :users, :nickname, unique: true
    add_index :users, :phone, unique: true
    add_index :users, :city
    add_index :users, :district
    add_index :users, :profile_completed
  end
end
