class CreateTeamsAndTeamMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.references :captain, null: false, foreign_key: { to_table: :users }
      t.text :description
      t.string :logo_url
      t.string :home_court
      t.string :city
      t.string :district
      t.boolean :is_active, default: true
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :tournaments_participated, default: 0
      t.timestamps
    end
    
    create_table :team_members do |t|
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, default: 'player'
      t.integer :jersey_number
      t.boolean :is_active, default: true
      t.datetime :joined_at
      t.timestamps
    end
    
    add_index :teams, [:captain_id, :name], unique: true
    add_index :teams, :is_active
    add_index :team_members, [:team_id, :user_id], unique: true
    add_index :team_members, [:team_id, :jersey_number], unique: true
    add_index :team_members, :role
    
    # TournamentTeam에 team_id 추가
    add_reference :tournament_teams, :team, foreign_key: true
  end
end