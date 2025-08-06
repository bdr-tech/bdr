class CreateSeasonAverages < ActiveRecord::Migration[8.0]
  def change
    create_table :season_averages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :season_name # "2024 Spring", "2024 Summer", etc.
      t.date :season_start
      t.date :season_end

      # Game stats
      t.integer :games_played, default: 0
      t.integer :games_started, default: 0
      t.integer :wins, default: 0
      t.integer :losses, default: 0

      # Per game averages
      t.decimal :minutes_per_game, precision: 5, scale: 2, default: 0.0
      t.decimal :points_per_game, precision: 5, scale: 2, default: 0.0
      t.decimal :rebounds_per_game, precision: 5, scale: 2, default: 0.0
      t.decimal :assists_per_game, precision: 5, scale: 2, default: 0.0
      t.decimal :steals_per_game, precision: 5, scale: 2, default: 0.0
      t.decimal :blocks_per_game, precision: 5, scale: 2, default: 0.0
      t.decimal :turnovers_per_game, precision: 5, scale: 2, default: 0.0

      # Shooting percentages
      t.decimal :field_goal_percentage, precision: 5, scale: 2, default: 0.0
      t.decimal :three_point_percentage, precision: 5, scale: 2, default: 0.0
      t.decimal :free_throw_percentage, precision: 5, scale: 2, default: 0.0

      # Advanced stats
      t.decimal :player_efficiency_rating, precision: 5, scale: 2, default: 0.0
      t.decimal :true_shooting_percentage, precision: 5, scale: 2, default: 0.0
      t.decimal :usage_rate, precision: 5, scale: 2, default: 0.0

      t.timestamps
    end

    add_index :season_averages, [ :user_id, :season_name ], unique: true
    add_index :season_averages, [ :user_id, :season_start ]
    add_index :season_averages, :points_per_game
  end
end
