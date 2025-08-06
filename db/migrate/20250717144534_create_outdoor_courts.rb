class CreateOutdoorCourts < ActiveRecord::Migration[8.0]
  def change
    create_table :outdoor_courts do |t|
      t.string :title, null: false
      t.string :image1, null: false
      t.string :image2, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :address, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :outdoor_courts, [ :latitude, :longitude ]
  end
end
