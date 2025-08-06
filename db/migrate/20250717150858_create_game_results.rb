class CreateGameResults < ActiveRecord::Migration[8.0]
  def change
    create_table :game_results do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :team # 'home' or 'away'
      t.boolean :won, default: false
      t.decimal :player_rating, precision: 3, scale: 2, default: 0.0
      t.integer :points_scored, default: 0
      t.integer :assists, default: 0
      t.integer :rebounds, default: 0

      t.timestamps
    end

    add_index :game_results, [ :game_id, :user_id ], unique: true
    # user_id index already created by references
  end
end
