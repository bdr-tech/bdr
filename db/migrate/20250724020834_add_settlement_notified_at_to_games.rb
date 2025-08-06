class AddSettlementNotifiedAtToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :settlement_notified_at, :datetime
  end
end
