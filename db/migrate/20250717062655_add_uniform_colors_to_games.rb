class AddUniformColorsToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :home_team_color, :string, default: '흰색'
    add_column :games, :away_team_color, :string, default: '검은색'
  end
end
