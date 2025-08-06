class CreateTournamentAiAndAutomationTables < ActiveRecord::Migration[7.0]
  def change
    # AI 포스터 생성 기록
    create_table :ai_poster_generations do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :prompt_used, limit: 1000
      t.string :style_selected
      t.string :image_url
      t.boolean :selected_by_user, default: false
      t.integer :generation_time_ms
      t.decimal :api_cost, precision: 10, scale: 2
      t.string :status, default: 'pending'
      t.text :error_message
      t.timestamps
    end

    # 대회 템플릿
    create_table :tournament_templates do |t|
      t.string :name, null: false
      t.string :template_type # weekend_league, 3x3_speed, company_friendly, etc.
      t.integer :default_team_count
      t.integer :estimated_duration_hours
      t.string :default_format # single_elimination, round_robin, etc.
      t.text :default_rules
      t.boolean :is_popular, default: false
      t.integer :usage_count, default: 0
      t.string :category # official, community, enterprise, special
      t.boolean :is_premium_only, default: false
      t.json :configuration # 추가 설정 옵션
      t.timestamps
    end

    # 대회 자동화 워크플로우
    create_table :tournament_automations do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :automation_type # marketing_campaign, bracket_generation, result_processing, etc.
      t.string :status, default: 'scheduled'
      t.json :configuration
      t.datetime :scheduled_at
      t.datetime :executed_at
      t.text :execution_log
      t.integer :retry_count, default: 0
      t.timestamps
    end

    # 자동 마케팅 캠페인 기록
    create_table :tournament_marketing_campaigns do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :campaign_type # early_bird, reminder, final_call, etc.
      t.string :channel # email, sms, push, sns
      t.integer :recipients_count
      t.integer :opens_count, default: 0
      t.integer :clicks_count, default: 0
      t.datetime :sent_at
      t.json :content
      t.timestamps
    end

    # 인덱스 추가
    add_index :ai_poster_generations, :selected_by_user
    add_index :tournament_templates, :template_type
    add_index :tournament_templates, :is_popular
    add_index :tournament_automations, :automation_type
    add_index :tournament_automations, :status
    add_index :tournament_automations, :scheduled_at
    add_index :tournament_marketing_campaigns, :campaign_type
  end
end
