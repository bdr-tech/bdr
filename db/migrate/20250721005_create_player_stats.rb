class CreatePlayerStats < ActiveRecord::Migration[8.0]
  def change
    create_table :player_stats do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.references :game_result, foreign_key: true

      # Basic stats
      t.integer :minutes_played, default: 0
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

      # Advanced stats
      t.decimal :plus_minus, precision: 5, scale: 1, default: 0.0
      t.decimal :player_efficiency_rating, precision: 5, scale: 2, default: 0.0
      t.decimal :true_shooting_percentage, precision: 5, scale: 2, default: 0.0
      t.decimal :effective_field_goal_percentage, precision: 5, scale: 2, default: 0.0

      t.timestamps
    end

    add_index :player_stats, [ :user_id, :game_id ], unique: true
    add_index :player_stats, [ :user_id, :created_at ]
    add_index :player_stats, :points
  end
end
