class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.json :data
      t.references :notifiable, polymorphic: true
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false
      t.datetime :read_at
      t.datetime :sent_at

      t.timestamps
    end

    add_index :notifications, :notification_type
    add_index :notifications, :status
    add_index :notifications, :priority
    add_index :notifications, [ :user_id, :status ]
    add_index :notifications, [ :user_id, :created_at ]
  end
end
