class AddRealtimeFieldsToCourts < ActiveRecord::Migration[8.0]
  def change
    add_column :courts, :current_occupancy, :integer, default: 0
    add_column :courts, :last_activity_at, :datetime
    add_column :courts, :peak_hours, :json, default: {}
    add_column :courts, :average_occupancy, :float, default: 0.0
    add_column :courts, :realtime_enabled, :boolean, default: false

    add_index :courts, :last_activity_at
    add_index :courts, :current_occupancy
  end
end
