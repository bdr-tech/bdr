class CreateTournamentPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_players do |t|
      t.references :tournament_team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :position
      t.integer :jersey_number
      t.boolean :is_starter, default: false
      t.boolean :is_active, default: true
      t.timestamps
    end
    
    add_index :tournament_players, [:tournament_team_id, :user_id], unique: true
    add_index :tournament_players, [:tournament_team_id, :jersey_number], unique: true
  end
end