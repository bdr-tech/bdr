class CreateUserStats < ActiveRecord::Migration[8.0]
  def change
    create_table :user_stats do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :rating, precision: 3, scale: 2, default: 0.0
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :games_played, default: 0
      t.integer :mvp_count, default: 0

      t.timestamps
    end

    # user_id index already created by references
  end
end
