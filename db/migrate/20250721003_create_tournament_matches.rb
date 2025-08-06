class CreateTournamentMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_matches do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :home_team, foreign_key: { to_table: :tournament_teams }
      t.references :away_team, foreign_key: { to_table: :tournament_teams }
      t.string :round # round_of_16, quarter_final, semi_final, final, group_a, group_b, etc
      t.integer :match_number
      t.datetime :scheduled_at
      t.string :court_name
      t.string :status, default: 'scheduled' # scheduled, ongoing, completed, cancelled
      t.integer :home_score
      t.integer :away_score
      t.references :winner_team, foreign_key: { to_table: :tournament_teams }
      t.text :match_notes
      t.string :referee_names

      t.timestamps
    end

    add_index :tournament_matches, [ :tournament_id, :round ]
    add_index :tournament_matches, [ :tournament_id, :scheduled_at ]
    add_index :tournament_matches, :status
  end
end
