class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.references :rated_user, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :comment
      t.string :rating_type, null: false, default: 'player'

      t.timestamps
    end

    add_index :ratings, [ :user_id, :game_id, :rated_user_id ], unique: true
    add_index :ratings, [ :rated_user_id, :created_at ]
    add_index :ratings, :rating_type
  end
end
