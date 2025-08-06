class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :city, null: false
      t.string :district, null: false
      t.string :full_name, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end

    add_index :locations, [ :city, :district ], unique: true
    add_index :locations, :full_name
  end
end
