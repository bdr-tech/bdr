class CreateCourts < ActiveRecord::Migration[8.0]
  def change
    create_table :courts do |t|
      t.string :name
      t.string :address
      t.decimal :latitude
      t.decimal :longitude
      t.string :court_type
      t.integer :capacity

      t.timestamps
    end
  end
end
