class AddEnhancedFieldsToTournaments < ActiveRecord::Migration[7.0]
  def change
    # 대회 운영 주체 구분
    add_column :tournaments, :is_official, :boolean, default: false
    add_column :tournaments, :created_by_premium_user, :boolean, default: false

    # 템플릿 및 AI 기능
    add_column :tournaments, :template_used, :string
    add_column :tournaments, :ai_poster_generated, :boolean, default: false
    add_column :tournaments, :poster_style, :string
    add_column :tournaments, :poster_image_url, :string

    # 자동화 기능
    add_column :tournaments, :auto_bracket_generated, :boolean, default: false
    add_column :tournaments, :live_streaming_enabled, :boolean, default: false
    add_column :tournaments, :auto_notification_enabled, :boolean, default: true

    # 수수료 및 정산
    add_column :tournaments, :platform_fee_percentage, :decimal, precision: 5, scale: 2, default: 5.0
    add_column :tournaments, :actual_platform_fee, :decimal, precision: 10, scale: 2
    add_column :tournaments, :total_revenue, :decimal, precision: 10, scale: 2
    add_column :tournaments, :settlement_status, :string
    add_column :tournaments, :settlement_completed_at, :datetime

    # 인덱스 추가
    add_index :tournaments, :is_official
    add_index :tournaments, :created_by_premium_user
    add_index :tournaments, :settlement_status
  end
end
