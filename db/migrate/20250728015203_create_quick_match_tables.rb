class CreateQuickMatchTables < ActiveRecord::Migration[7.0]
  def change
    # 퀵매치 선호도 설정
    create_table :quick_match_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.json :preferred_times # {"monday": ["evening"], "tuesday": ["evening", "night"]}
      t.json :preferred_locations # ["gangnam", "seocho"]
      t.integer :preferred_level_range, default: 1 # ±1 level tolerance
      t.integer :max_distance_km, default: 10
      t.boolean :auto_match_enabled, default: false
      t.json :preferred_game_types, default: [] # ["pickup", "guest", "team_vs_team"]
      t.integer :min_players, default: 6
      t.integer :max_players, default: 10
      t.timestamps
    end

    # 매치 풀 (매칭 대기열)
    create_table :match_pools do |t|
      t.string :city, null: false
      t.string :district
      t.datetime :match_time, null: false
      t.integer :skill_level
      t.integer :current_players, default: 0
      t.integer :min_players, default: 6
      t.integer :max_players, default: 10
      t.string :status, default: 'forming' # forming, ready, game_created, cancelled
      t.string :game_type, default: 'pickup'
      t.references :created_game, foreign_key: { to_table: :games }
      t.json :player_ids, default: []
      t.timestamps
    end

    # 매치 풀 참가자
    create_table :match_pool_participants do |t|
      t.references :match_pool, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'waiting' # waiting, confirmed, declined
      t.datetime :joined_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :confirmed_at
      t.timestamps
    end

    # 퀵매치 기록
    create_table :quick_match_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, foreign_key: true
      t.references :match_pool, foreign_key: true
      t.string :match_type # instant_match, pool_match
      t.integer :search_time_seconds
      t.boolean :successful, default: false
      t.json :search_criteria
      t.timestamps
    end

    # 인덱스 추가
    add_index :quick_match_preferences, :auto_match_enabled
    add_index :match_pools, [ :city, :district ]
    add_index :match_pools, :match_time
    add_index :match_pools, :status
    add_index :match_pool_participants, [ :match_pool_id, :user_id ], unique: true
    add_index :quick_match_histories, :successful
  end
end
