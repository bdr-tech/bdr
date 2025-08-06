class AddTossPaymentsFieldsToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :toss_payment_key, :string
    add_column :payments, :toss_order_id, :string
  end
end
