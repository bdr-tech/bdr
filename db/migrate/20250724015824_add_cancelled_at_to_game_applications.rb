class AddCancelledAtToGameApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :game_applications, :cancelled_at, :datetime
  end
end
