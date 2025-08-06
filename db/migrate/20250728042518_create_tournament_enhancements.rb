class CreateTournamentEnhancements < ActiveRecord::Migration[8.0]
  def change
    # 대회 간편 생성 마법사 상태 저장
    create_table :tournament_wizards do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tournament, foreign_key: true
      t.string :step, default: 'template_selection'
      t.json :wizard_data, default: {}
      t.boolean :completed, default: false
      t.timestamps
    end

    # 모바일 QR 체크인 기록
    create_table :tournament_check_ins do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :tournament_team, foreign_key: true
      t.string :role # player, coach, spectator
      t.string :qr_code
      t.datetime :checked_in_at
      t.string :device_info
      t.timestamps
    end

    # 대회 실시간 업데이트
    create_table :tournament_live_updates do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :tournament_match, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :update_type # score_update, match_start, match_end, announcement
      t.json :data
      t.boolean :is_official, default: false
      t.timestamps
    end

    # 대회 미디어 (포스터, 하이라이트 등)
    create_table :tournament_media do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :media_type # poster, highlight, photo, certificate
      t.string :title
      t.text :description
      t.string :file_url
      t.json :metadata
      t.integer :views_count, default: 0
      t.integer :likes_count, default: 0
      t.timestamps
    end

    # 대회 예산 관리
    create_table :tournament_budgets do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :category # income, court_fee, prize, refreshment, platform_fee, etc
      t.string :description
      t.decimal :amount, precision: 10, scale: 2
      t.boolean :is_income, default: false
      t.datetime :transaction_date
      t.string :receipt_url
      t.timestamps
    end

    # 대회 공유 링크
    create_table :tournament_share_links do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :share_type # kakao, instagram, general
      t.string :short_code
      t.string :full_url
      t.integer :click_count, default: 0
      t.datetime :expires_at
      t.timestamps
    end

    # 대회 피드백
    create_table :tournament_feedback do |t|
      t.references :tournament, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :overall_rating
      t.text :comment
      t.json :ratings # { organization: 5, facility: 4, competition: 5, etc }
      t.boolean :would_participate_again, default: true
      t.timestamps
    end

    # 기존 tournaments 테이블에 간편 기능 관련 컬럼 추가
    add_column :tournaments, :template_type, :string
    add_column :tournaments, :is_quick_tournament, :boolean, default: false
    add_column :tournaments, :auto_bracket_generation, :boolean, default: true
    add_column :tournaments, :auto_score_calculation, :boolean, default: true
    add_column :tournaments, :mobile_optimized, :boolean, default: true
    add_column :tournaments, :share_settings, :json, default: {}
    add_column :tournaments, :notification_settings, :json, default: {}
    add_column :tournaments, :poster_template_id, :string
    add_column :tournaments, :poster_settings, :json, default: {}
    add_column :tournaments, :budget_settings, :json, default: {}
    add_column :tournaments, :special_events, :json, default: []
    add_column :tournaments, :prizes_info, :json, default: {}
    add_column :tournaments, :checkin_qr_code, :string
    add_column :tournaments, :organizer_notes, :text
    add_column :tournaments, :post_event_summary, :text

    # 인덱스 추가
    add_index :tournament_wizards, :step
    add_index :tournament_wizards, :completed
    add_index :tournament_check_ins, :qr_code
    add_index :tournament_check_ins, :checked_in_at
    add_index :tournament_live_updates, :update_type
    add_index :tournament_media, :media_type
    add_index :tournament_budgets, :category
    add_index :tournament_share_links, :short_code
    add_index :tournament_share_links, :share_type
    add_index :tournaments, :template_type
    add_index :tournaments, :is_quick_tournament
  end
end
