class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.string :name, null: false
      t.text :description
      t.text :query, null: false
      t.string :schedule # daily, weekly, monthly
      t.datetime :last_run
      t.datetime :next_run
      t.boolean :active, default: true
      t.json :parameters
      t.timestamps
    end

    add_index :reports, :name
    add_index :reports, :schedule
    add_index :reports, :active
  end
end
