class AddApprovalFieldsToTournaments < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :approved_at, :datetime
    add_column :tournaments, :rejected_at, :datetime
    add_column :tournaments, :approval_notes, :text
    add_column :tournaments, :rejection_reason, :text
  end
end
