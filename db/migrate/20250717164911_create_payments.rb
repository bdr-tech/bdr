class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :game_application, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.string :payment_method
      t.text :bdr_account_info
      t.datetime :paid_at
      t.datetime :transferred_to_host_at

      t.timestamps
    end
  end
end
