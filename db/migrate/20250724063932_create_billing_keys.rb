class CreateBillingKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :billing_keys do |t|
      t.references :user, null: false, foreign_key: true
      t.string :customer_key, null: false
      t.string :billing_key, null: false
      t.string :card_number, null: false # 카드 번호 마스킹 (ex: 1234-****-****-5678)
      t.string :card_company
      t.string :card_type # 신용/체크
      t.boolean :is_active, default: true
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :billing_keys, :customer_key, unique: true
    add_index :billing_keys, :billing_key, unique: true
    add_index :billing_keys, [ :user_id, :is_active ]
  end
end
