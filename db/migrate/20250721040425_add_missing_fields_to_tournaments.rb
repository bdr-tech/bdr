class AddMissingFieldsToTournaments < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :venue, :string
    add_column :tournaments, :contact_info, :text
    add_column :tournaments, :is_featured, :boolean, default: false
    add_column :tournaments, :prize_info, :text
  end
end
