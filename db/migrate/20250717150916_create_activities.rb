class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :activity_type, null: false
      t.references :trackable, polymorphic: true, null: false
      t.text :metadata # JSON data for additional activity info

      t.timestamps
    end

    add_index :activities, [ :user_id, :created_at ]
    add_index :activities, [ :trackable_type, :trackable_id ]
    add_index :activities, :activity_type
  end
end
