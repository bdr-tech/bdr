class CreateUserCancellations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_cancellations do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :cancellation_count, default: 0
      t.datetime :last_cancelled_at

      t.timestamps
    end
  end
end
