class AddAnalyticsFieldsToExistingTables < ActiveRecord::Migration[8.0]
  def change
    # Users 테이블에 분석용 필드 추가
    add_column :users, :last_activity_at, :datetime
    add_column :users, :registration_source, :string # web, mobile, etc
    add_column :users, :referrer_url, :string
    add_column :users, :marketing_consent, :boolean, default: false
    add_column :users, :profile_views, :integer, default: 0
    add_column :users, :total_games_hosted, :integer, default: 0
    add_column :users, :total_games_participated, :integer, default: 0
    add_column :users, :total_revenue, :decimal, precision: 10, scale: 2, default: 0
    add_column :users, :average_rating, :decimal, precision: 3, scale: 2, default: 0
    add_column :users, :reliability_score, :decimal, precision: 3, scale: 2, default: 5.0

    # Games 테이블에 분석용 필드 추가
    add_column :games, :view_count, :integer, default: 0
    add_column :games, :application_count, :integer, default: 0
    add_column :games, :completion_rate, :decimal, precision: 5, scale: 2, default: 0
    add_column :games, :average_rating, :decimal, precision: 3, scale: 2, default: 0
    add_column :games, :revenue_generated, :decimal, precision: 10, scale: 2, default: 0
    add_column :games, :platform_fee, :decimal, precision: 10, scale: 2, default: 0
    add_column :games, :host_payout, :decimal, precision: 10, scale: 2, default: 0
    add_column :games, :weather_cancelled, :boolean, default: false
    add_column :games, :no_show_count, :integer, default: 0

    # Payments 테이블에 분석용 필드 추가 (기존 필드 제외)
    add_column :payments, :processing_time, :integer # seconds
    add_column :payments, :fee_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :payments, :net_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :payments, :currency, :string, default: 'KRW'

    # GameApplications 테이블에 분석용 필드 추가
    add_column :game_applications, :response_time, :integer # seconds from application to approval/rejection
    add_column :game_applications, :cancellation_reason, :string
    add_column :game_applications, :showed_up, :boolean
    add_column :game_applications, :rating_given, :decimal, precision: 3, scale: 2
    add_column :game_applications, :rating_received, :decimal, precision: 3, scale: 2

    # 인덱스 추가
    add_index :users, :last_activity_at
    add_index :users, :registration_source
    add_index :users, :total_games_hosted
    add_index :users, :total_games_participated
    add_index :users, :average_rating
    add_index :users, :reliability_score

    add_index :games, :view_count
    add_index :games, :application_count
    add_index :games, :completion_rate
    add_index :games, :average_rating
    add_index :games, :revenue_generated
    add_index :games, :weather_cancelled

    add_index :payments, :processing_time
    add_index :payments, :fee_amount
    add_index :payments, :net_amount
    add_index :payments, :currency

    add_index :game_applications, :response_time
    add_index :game_applications, :showed_up
    add_index :game_applications, :rating_given
    add_index :game_applications, :rating_received
  end
end
