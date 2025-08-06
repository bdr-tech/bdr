class AddTemplateReferenceToTournaments < ActiveRecord::Migration[8.0]
  def change
    add_reference :tournaments, :tournament_template, foreign_key: true
    add_column :tournaments, :progress_percentage, :integer, default: 0
    add_column :tournaments, :current_round, :string
    add_column :tournaments, :quick_action_buttons, :json
  end
end
