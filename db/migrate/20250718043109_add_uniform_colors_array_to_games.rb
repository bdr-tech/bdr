class AddUniformColorsArrayToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :uniform_colors, :text
  end
end
