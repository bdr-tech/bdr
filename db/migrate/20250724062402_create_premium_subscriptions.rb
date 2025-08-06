class CreatePremiumSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :premium_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :plan_type, null: false
      t.string :payment_key, null: false
      t.string :order_id, null: false
      t.integer :amount, null: false
      t.string :status, null: false, default: 'active'
      t.datetime :started_at, null: false
      t.datetime :cancelled_at
      t.datetime :refunded_at
      t.integer :refund_amount

      t.timestamps
    end

    add_index :premium_subscriptions, :payment_key, unique: true
    add_index :premium_subscriptions, :order_id, unique: true
    add_index :premium_subscriptions, :status
    add_index :premium_subscriptions, :plan_type
  end
end
