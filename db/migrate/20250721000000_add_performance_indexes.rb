class AddPerformanceIndexes < ActiveRecord::Migration[7.0]
  def change
    # Indexes for notifications table
    add_index :notifications, [ :user_id, :status ], name: 'index_notifications_on_user_id_and_status', if_not_exists: true
    add_index :notifications, [ :user_id, :created_at ], name: 'index_notifications_on_user_id_and_created_at', if_not_exists: true
    add_index :notifications, [ :notifiable_type, :notifiable_id ], name: 'index_notifications_on_notifiable', if_not_exists: true
    add_index :notifications, :status, name: 'index_notifications_on_status', if_not_exists: true
    add_index :notifications, :notification_type, name: 'index_notifications_on_notification_type', if_not_exists: true
    add_index :notifications, :priority, name: 'index_notifications_on_priority', if_not_exists: true

    # Composite indexes for frequently queried combinations
    add_index :games, [ :organizer_id, :scheduled_at ], name: 'index_games_on_organizer_id_and_scheduled_at', if_not_exists: true
    add_index :games, [ :status, :scheduled_at ], name: 'index_games_on_status_and_scheduled_at', if_not_exists: true

    # Index for game applications filtering
    add_index :game_applications, [ :user_id, :created_at ], name: 'index_game_applications_on_user_id_and_created_at', if_not_exists: true

    # Index for posts filtering
    add_index :posts, [ :user_id, :created_at ], name: 'index_posts_on_user_id_and_created_at', if_not_exists: true
    add_index :posts, [ :category, :created_at ], name: 'index_posts_on_category_and_created_at', if_not_exists: true

    # Index for locations lookup
    add_index :locations, :city, name: 'index_locations_on_city', if_not_exists: true

    # Index for courts lookup
    add_index :courts, :court_type, name: 'index_courts_on_court_type', if_not_exists: true
    add_index :courts, [ :latitude, :longitude ], name: 'index_courts_on_latitude_and_longitude', if_not_exists: true

    # Index for user lookups
    add_index :users, :created_at, name: 'index_users_on_created_at', if_not_exists: true
    add_index :users, [ :city, :district, :created_at ], name: 'index_users_on_city_district_created_at', if_not_exists: true

    # Index for admin logs filtering
    add_index :admin_logs, [ :user_id, :created_at ], name: 'index_admin_logs_on_user_id_and_created_at', if_not_exists: true

    # Index for payments lookup
    add_index :payments, [ :game_application_id, :status ], name: 'index_payments_on_game_application_id_and_status', if_not_exists: true
    add_index :payments, :created_at, name: 'index_payments_on_created_at', if_not_exists: true

    # Index for outdoor courts
    add_index :outdoor_courts, :created_at, name: 'index_outdoor_courts_on_created_at', if_not_exists: true
    add_index :outdoor_courts, [ :user_id, :created_at ], name: 'index_outdoor_courts_on_user_id_and_created_at', if_not_exists: true
  end
end
