class AddPartialSettlementFieldsToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :final_player_count, :integer
    add_column :games, :closed_at, :datetime
    add_column :games, :actual_revenue, :decimal, precision: 10, scale: 2
    add_column :games, :actual_platform_fee, :decimal, precision: 10, scale: 2
    add_column :games, :actual_host_revenue, :decimal, precision: 10, scale: 2
    add_column :games, :is_partial_settlement, :boolean, default: false
  end
end
