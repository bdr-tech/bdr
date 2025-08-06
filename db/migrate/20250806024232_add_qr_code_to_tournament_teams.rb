class AddQrCodeToTournamentTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :tournament_teams, :qr_token, :string
    add_column :tournament_teams, :checked_in, :boolean, default: false
    add_column :tournament_teams, :checked_in_at, :datetime
    
    add_index :tournament_teams, :qr_token, unique: true
  end
end
