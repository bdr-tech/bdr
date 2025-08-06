class DropHostCertificationsTable < ActiveRecord::Migration[8.0]
  def up
    # Remove foreign key if exists
    if foreign_key_exists?(:host_certifications, :users)
      remove_foreign_key :host_certifications, :users
    end

    # Drop the table
    drop_table :host_certifications if table_exists?(:host_certifications)
  end

  def down
    create_table :host_certifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :certification_type, null: false
      t.string :status, default: "pending"
      t.text :documents
      t.text :experience_description
      t.integer :games_hosted_count, default: 0
      t.datetime :approved_at
      t.datetime :rejected_at
      t.text :rejection_reason
      t.datetime :expires_at
      t.timestamps
    end

    add_index :host_certifications, :status
    add_index :host_certifications, :certification_type
  end
end
