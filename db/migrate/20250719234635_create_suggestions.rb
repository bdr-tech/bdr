class CreateSuggestions < ActiveRecord::Migration[8.0]
  def change
    create_table :suggestions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.string :status, default: 'pending', null: false
      t.text :admin_response

      t.timestamps
    end

    add_index :suggestions, :status
    add_index :suggestions, :created_at
  end
end
