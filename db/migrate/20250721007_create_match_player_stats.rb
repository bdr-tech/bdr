class CreateMatchPlayerStats < ActiveRecord::Migration[8.0]
  def change
    create_table :match_player_stats do |t|
      t.references :tournament_match, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :tournament_team, null: false, foreign_key: true
      t.string :team_type # home or away

      # Playing time
      t.integer :minutes_played, default: 0
      t.boolean :starter, default: false

      # Scoring
      t.integer :points, default: 0
      t.integer :field_goals_made, default: 0
      t.integer :field_goals_attempted, default: 0
      t.integer :three_pointers_made, default: 0
      t.integer :three_pointers_attempted, default: 0
      t.integer :free_throws_made, default: 0
      t.integer :free_throws_attempted, default: 0

      # Rebounds
      t.integer :offensive_rebounds, default: 0
      t.integer :defensive_rebounds, default: 0
      t.integer :total_rebounds, default: 0

      # Other stats
      t.integer :assists, default: 0
      t.integer :steals, default: 0
      t.integer :blocks, default: 0
      t.integer :turnovers, default: 0
      t.integer :personal_fouls, default: 0

      # Advanced
      t.decimal :plus_minus, precision: 5, scale: 1, default: 0.0

      t.timestamps
    end

    add_index :match_player_stats, [ :tournament_match_id, :user_id ], unique: true
    add_index :match_player_stats, :points
    add_index :match_player_stats, :team_type

    # Add quarter scores to tournament_matches
    add_column :tournament_matches, :quarter_scores, :json
    add_column :tournament_matches, :overtime_scores, :json
    add_column :tournament_matches, :game_duration, :integer # in minutes
  end
end
