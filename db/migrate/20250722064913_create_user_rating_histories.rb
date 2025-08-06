class CreateUserRatingHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :user_rating_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :rating_before, precision: 5, scale: 3
      t.decimal :rating_after, precision: 5, scale: 3
      t.decimal :rating_change, precision: 5, scale: 3
      t.string :change_reason
      t.references :game, null: false, foreign_key: true
      t.integer :evaluation_count
      t.integer :positive_count
      t.integer :negative_count

      t.timestamps
    end

    add_index :user_rating_histories, [ :user_id, :created_at ]
  end
end
