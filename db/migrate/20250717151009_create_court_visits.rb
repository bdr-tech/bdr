class CreateCourtVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :court_visits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :court, null: false, foreign_key: true
      t.integer :visit_count, default: 0
      t.boolean :is_favorite, default: false
      t.datetime :last_visited_at

      t.timestamps
    end

    add_index :court_visits, [ :user_id, :court_id ], unique: true
    add_index :court_visits, [ :user_id, :is_favorite ]
    add_index :court_visits, :visit_count
  end
end
