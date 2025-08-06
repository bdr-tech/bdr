class AddTournamentHostingFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    # 대회 개최 관련 필드
    add_column :users, :tournaments_hosted_count, :integer, default: 0
    add_column :users, :tournament_host_rating, :decimal, precision: 3, scale: 2
    add_column :users, :can_create_tournaments, :boolean, default: false
    add_column :users, :max_concurrent_tournaments, :integer, default: 0

    # 매칭 우선순위 관련
    add_column :users, :quick_match_priority, :integer, default: 0
    add_column :users, :last_quick_match_at, :datetime

    # 인덱스 추가
    add_index :users, :can_create_tournaments
    add_index :users, :quick_match_priority
  end
end
