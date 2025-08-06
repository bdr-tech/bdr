class CreateAdminLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :resource_type, null: false
      t.integer :resource_id
      t.text :details
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end

    add_index :admin_logs, :action
    add_index :admin_logs, :resource_type
    add_index :admin_logs, [ :resource_type, :resource_id ]
    add_index :admin_logs, :created_at
  end
end
