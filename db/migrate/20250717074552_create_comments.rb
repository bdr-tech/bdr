class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.references :parent, null: true, foreign_key: { to_table: :comments }
      t.integer :depth, default: 0

      t.timestamps
    end

    add_index :comments, :created_at
    add_index :comments, [ :post_id, :parent_id ]
  end
end
