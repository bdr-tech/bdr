class AddDescriptionToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :description, :text
  end
end
