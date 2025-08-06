class AddFacilitiesToCourts < ActiveRecord::Migration[8.0]
  def change
    add_column :courts, :water_fountain, :boolean, default: false
    add_column :courts, :shower_available, :boolean, default: false
    add_column :courts, :parking_available, :boolean, default: false
    add_column :courts, :smoking_allowed, :boolean, default: false
    add_column :courts, :air_conditioning, :boolean, default: false
    add_column :courts, :locker_room, :boolean, default: false
    add_column :courts, :equipment_rental, :boolean, default: false
  end
end
