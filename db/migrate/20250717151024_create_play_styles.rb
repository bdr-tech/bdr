class CreatePlayStyles < ActiveRecord::Migration[8.0]
  def change
    create_table :play_styles do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :assist_percentage, default: 0
      t.integer :three_point_percentage, default: 0
      t.integer :defense_percentage, default: 0
      t.integer :rebound_percentage, default: 0

      t.timestamps
    end

    # user_id index already created by references
  end
end
