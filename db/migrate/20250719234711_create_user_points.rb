class CreateUserPoints < ActiveRecord::Migration[8.0]
  def change
    create_table :user_points do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :points, null: false, default: 0
      t.string :description, null: false
      t.string :transaction_type, null: false

      t.timestamps
    end

    add_index :user_points, :transaction_type
    add_index :user_points, :created_at

    # Add total_points column to users table
    add_column :users, :total_points, :integer, default: 0
  end
end
