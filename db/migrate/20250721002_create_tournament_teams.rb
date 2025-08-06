class CreateTournamentTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_teams do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :team_name, null: false
      t.references :captain, foreign_key: { to_table: :users }
      t.string :status, default: 'pending' # pending, approved, rejected, withdrawn
      t.text :roster # JSON array of player info
      t.string :contact_phone
      t.string :contact_email
      t.text :notes
      t.datetime :registered_at
      t.datetime :approved_at
      t.boolean :payment_completed, default: false
      t.datetime :payment_completed_at
      t.integer :seed_number
      t.integer :final_rank
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :points_for, default: 0
      t.integer :points_against, default: 0

      t.timestamps
    end

    add_index :tournament_teams, [ :tournament_id, :status ]
    add_index :tournament_teams, [ :tournament_id, :team_name ], unique: true
  end
end
