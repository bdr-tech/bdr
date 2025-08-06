class AddRefundFieldsToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :toss_refund_id, :string
    add_column :payments, :refund_status, :string
  end
end
