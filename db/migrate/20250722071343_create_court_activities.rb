class CreateCourtActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :court_activities do |t|
      t.references :court, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :activity_type, null: false
      t.integer :player_count, default: 0
      t.datetime :recorded_at, null: false
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :court_activities, [ :court_id, :recorded_at ]
    add_index :court_activities, :activity_type
  end
end
