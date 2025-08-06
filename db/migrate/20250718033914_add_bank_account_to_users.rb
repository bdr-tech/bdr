class AddBankAccountToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :bank_name, :string
    add_column :users, :account_number, :string
    add_column :users, :account_holder, :string
  end
end
