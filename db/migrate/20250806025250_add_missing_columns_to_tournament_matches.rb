class AddMissingColumnsToTournamentMatches < ActiveRecord::Migration[8.0]
  def change
    add_column :tournament_matches, :round_name, :string unless column_exists?(:tournament_matches, :round_name)
    add_column :tournament_matches, :group, :string unless column_exists?(:tournament_matches, :group)
    add_column :tournament_matches, :court_number, :integer unless column_exists?(:tournament_matches, :court_number)
    add_column :tournament_matches, :status, :string, default: 'scheduled' unless column_exists?(:tournament_matches, :status)
    
    add_column :tournaments, :brackets_published, :boolean, default: false unless column_exists?(:tournaments, :brackets_published)
    add_column :tournaments, :brackets_published_at, :datetime unless column_exists?(:tournaments, :brackets_published_at)
    add_column :tournaments, :paused_at, :datetime unless column_exists?(:tournaments, :paused_at)
    
    add_index :tournament_matches, :status unless index_exists?(:tournament_matches, :status)
    # round_number column might not exist, so skip index
  end
end
