class CreateSystemSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :system_settings do |t|
      t.string :key, null: false
      t.text :value
      t.text :description
      t.string :category, null: false
      t.boolean :editable, default: true
      t.timestamps
    end

    add_index :system_settings, :key, unique: true
    add_index :system_settings, :category
  end
end
