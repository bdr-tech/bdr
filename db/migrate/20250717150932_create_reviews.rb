class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reviewable, polymorphic: true, null: false
      t.integer :rating, null: false # 1-5 stars
      t.text :comment

      t.timestamps
    end

    add_index :reviews, [ :reviewable_type, :reviewable_id ]
    add_index :reviews, [ :user_id, :reviewable_type, :reviewable_id ], unique: true, name: 'index_reviews_on_user_and_reviewable'
  end
end
