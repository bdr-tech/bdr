class CreateTournaments < ActiveRecord::Migration[8.0]
  def change
    create_table :tournaments do |t|
      t.string :name, null: false
      t.text :description
      t.string :tournament_type # single_elimination, double_elimination, round_robin, group_stage
      t.string :status, default: 'draft' # draft, published, registration_open, registration_closed, ongoing, completed, cancelled
      t.datetime :registration_start_at
      t.datetime :registration_end_at
      t.datetime :tournament_start_at
      t.datetime :tournament_end_at
      t.integer :min_teams, default: 4
      t.integer :max_teams, default: 16
      t.integer :players_per_team, default: 5
      t.decimal :entry_fee, precision: 10, scale: 2, default: 0
      t.decimal :prize_pool, precision: 10, scale: 2, default: 0
      t.string :location_name
      t.string :location_address
      t.decimal :location_latitude, precision: 10, scale: 6
      t.decimal :location_longitude, precision: 10, scale: 6
      t.references :organizer, foreign_key: { to_table: :users }
      t.string :contact_phone
      t.string :contact_email
      t.text :rules
      t.text :prizes # JSON array of prizes
      t.string :sponsor_names
      t.string :poster_image
      t.string :banner_image
      t.boolean :featured, default: false
      t.integer :view_count, default: 0

      t.timestamps
    end

    add_index :tournaments, :status
    add_index :tournaments, :tournament_start_at
    add_index :tournaments, :registration_start_at
    add_index :tournaments, :featured
    add_index :tournaments, [ :status, :tournament_start_at ]
  end
end
