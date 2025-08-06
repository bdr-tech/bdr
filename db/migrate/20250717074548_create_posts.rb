class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.string :category, null: false
      t.string :image1
      t.string :image2
      t.integer :views_count, default: 0
      t.integer :comments_count, default: 0

      t.timestamps
    end

    add_index :posts, :category
    add_index :posts, :created_at
    add_index :posts, :views_count
  end
end
