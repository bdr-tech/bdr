# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_06_034630) do
  create_table "achievements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "icon"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "activity_type", null: false
    t.string "trackable_type", null: false
    t.integer "trackable_id", null: false
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type"], name: "index_activities_on_activity_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
    t.index ["user_id", "created_at"], name: "index_activities_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "admin_logs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "action", null: false
    t.string "resource_type", null: false
    t.integer "resource_id"
    t.text "details"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_admin_logs_on_action"
    t.index ["created_at"], name: "index_admin_logs_on_created_at"
    t.index ["resource_type", "resource_id"], name: "index_admin_logs_on_resource_type_and_resource_id"
    t.index ["resource_type"], name: "index_admin_logs_on_resource_type"
    t.index ["user_id", "created_at"], name: "index_admin_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_admin_logs_on_user_id"
  end

  create_table "ai_poster_generations", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.string "prompt_used", limit: 1000
    t.string "style_selected"
    t.string "image_url"
    t.boolean "selected_by_user", default: false
    t.integer "generation_time_ms"
    t.decimal "api_cost", precision: 10, scale: 2
    t.string "status", default: "pending"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["selected_by_user"], name: "index_ai_poster_generations_on_selected_by_user"
    t.index ["tournament_id"], name: "index_ai_poster_generations_on_tournament_id"
  end

  create_table "billing_keys", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "customer_key", null: false
    t.string "billing_key", null: false
    t.string "card_number", null: false
    t.string "card_company"
    t.string "card_type"
    t.boolean "is_active", default: true
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_key"], name: "index_billing_keys_on_billing_key", unique: true
    t.index ["customer_key"], name: "index_billing_keys_on_customer_key", unique: true
    t.index ["user_id", "is_active"], name: "index_billing_keys_on_user_id_and_is_active"
    t.index ["user_id"], name: "index_billing_keys_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "user_id", null: false
    t.text "content", null: false
    t.integer "parent_id"
    t.integer "depth", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["post_id", "parent_id"], name: "index_comments_on_post_id_and_parent_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "court_activities", force: :cascade do |t|
    t.integer "court_id", null: false
    t.integer "user_id", null: false
    t.string "activity_type", null: false
    t.integer "player_count", default: 0
    t.datetime "recorded_at", null: false
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type"], name: "index_court_activities_on_activity_type"
    t.index ["court_id", "recorded_at"], name: "index_court_activities_on_court_id_and_recorded_at"
    t.index ["court_id"], name: "index_court_activities_on_court_id"
    t.index ["user_id"], name: "index_court_activities_on_user_id"
  end

  create_table "court_visits", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "court_id", null: false
    t.integer "visit_count", default: 0
    t.boolean "is_favorite", default: false
    t.datetime "last_visited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_court_visits_on_court_id"
    t.index ["user_id", "court_id"], name: "index_court_visits_on_user_id_and_court_id", unique: true
    t.index ["user_id", "is_favorite"], name: "index_court_visits_on_user_id_and_is_favorite"
    t.index ["user_id"], name: "index_court_visits_on_user_id"
    t.index ["visit_count"], name: "index_court_visits_on_visit_count"
  end

  create_table "courts", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "court_type"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "water_fountain", default: false
    t.boolean "shower_available", default: false
    t.boolean "parking_available", default: false
    t.boolean "smoking_allowed", default: false
    t.boolean "air_conditioning", default: false
    t.boolean "locker_room", default: false
    t.boolean "equipment_rental", default: false
    t.string "image1"
    t.string "image2"
    t.integer "current_occupancy", default: 0
    t.datetime "last_activity_at"
    t.json "peak_hours", default: {}
    t.float "average_occupancy", default: 0.0
    t.boolean "realtime_enabled", default: false
    t.index ["court_type"], name: "index_courts_on_court_type"
    t.index ["current_occupancy"], name: "index_courts_on_current_occupancy"
    t.index ["last_activity_at"], name: "index_courts_on_last_activity_at"
    t.index ["latitude", "longitude"], name: "index_courts_on_latitude_and_longitude"
  end

  create_table "evaluation_deadlines", force: :cascade do |t|
    t.integer "game_id", null: false
    t.datetime "deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true, null: false
    t.index ["game_id"], name: "index_evaluation_deadlines_on_game_id"
  end

  create_table "game_applications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_id", null: false
    t.string "status"
    t.datetime "applied_at"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "payment_confirmed_at"
    t.datetime "final_approved_at"
    t.datetime "payment_deadline"
    t.datetime "auto_rejected_at"
    t.text "rejection_reason"
    t.integer "status_changed_by_user_id"
    t.text "status_change_reason"
    t.text "host_notes"
    t.text "guest_notes"
    t.datetime "reminder_sent_at"
    t.integer "reminder_count", default: 0
    t.datetime "last_contacted_at"
    t.integer "response_time"
    t.string "cancellation_reason"
    t.boolean "showed_up"
    t.decimal "rating_given", precision: 3, scale: 2
    t.decimal "rating_received", precision: 3, scale: 2
    t.datetime "cancelled_at"
    t.index ["auto_rejected_at"], name: "index_game_applications_on_auto_rejected_at"
    t.index ["final_approved_at"], name: "index_game_applications_on_final_approved_at"
    t.index ["game_id", "status"], name: "index_game_applications_on_game_id_and_status"
    t.index ["game_id"], name: "index_game_applications_on_game_id"
    t.index ["last_contacted_at"], name: "index_game_applications_on_last_contacted_at"
    t.index ["payment_confirmed_at"], name: "index_game_applications_on_payment_confirmed_at"
    t.index ["payment_deadline"], name: "index_game_applications_on_payment_deadline"
    t.index ["rating_given"], name: "index_game_applications_on_rating_given"
    t.index ["rating_received"], name: "index_game_applications_on_rating_received"
    t.index ["reminder_sent_at"], name: "index_game_applications_on_reminder_sent_at"
    t.index ["response_time"], name: "index_game_applications_on_response_time"
    t.index ["showed_up"], name: "index_game_applications_on_showed_up"
    t.index ["status"], name: "index_game_applications_on_status"
    t.index ["status_changed_by_user_id"], name: "index_game_applications_on_status_changed_by_user_id"
    t.index ["user_id", "created_at"], name: "index_game_applications_on_user_id_and_created_at"
    t.index ["user_id", "game_id"], name: "index_game_applications_unique_user_game", unique: true
    t.index ["user_id", "status"], name: "index_game_applications_on_user_id_and_status"
    t.index ["user_id"], name: "index_game_applications_on_user_id"
    t.check_constraint "reminder_count >= 0", name: "game_applications_reminder_count_positive_check"
    t.check_constraint "status IN ('pending', 'approved', 'waiting_payment', 'final_approved', 'rejected')", name: "game_applications_status_check"
  end

  create_table "game_participations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_id", null: false
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_participations_on_game_id"
    t.index ["user_id"], name: "index_game_participations_on_user_id"
  end

  create_table "game_results", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "user_id", null: false
    t.string "team"
    t.boolean "won", default: false
    t.decimal "player_rating", precision: 3, scale: 2, default: "0.0"
    t.integer "points_scored", default: 0
    t.integer "assists", default: 0
    t.integer "rebounds", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "user_id"], name: "index_game_results_on_game_id_and_user_id", unique: true
    t.index ["game_id"], name: "index_game_results_on_game_id"
    t.index ["user_id"], name: "index_game_results_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "court_id"
    t.integer "organizer_id"
    t.datetime "scheduled_at"
    t.string "status"
    t.integer "max_players"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "home_team_color", default: "흰색"
    t.string "away_team_color", default: "검은색"
    t.text "description"
    t.string "game_type"
    t.string "team_name"
    t.string "city"
    t.string "district"
    t.string "title"
    t.string "venue_name"
    t.string "venue_address"
    t.time "start_time"
    t.time "end_time"
    t.integer "level"
    t.integer "fee"
    t.boolean "parking_required", default: false
    t.boolean "shower_required", default: false
    t.boolean "water_fountain_required", default: false
    t.boolean "air_conditioning_required", default: false
    t.text "message"
    t.string "game_id", null: false
    t.integer "payment_deadline_hours", default: 24
    t.boolean "auto_approve_applications", default: false
    t.boolean "requires_payment", default: true
    t.text "payment_instructions"
    t.datetime "host_payment_transferred_at"
    t.decimal "host_payment_amount", precision: 10, scale: 2
    t.decimal "platform_fee_amount", precision: 10, scale: 2
    t.decimal "platform_fee_percentage", precision: 5, scale: 2, default: "5.0"
    t.datetime "cancelled_at"
    t.integer "cancelled_by_user_id"
    t.text "cancellation_reason"
    t.boolean "is_recurring", default: false
    t.string "recurring_pattern"
    t.integer "parent_game_id"
    t.integer "max_waitlist", default: 0
    t.boolean "waitlist_enabled", default: false
    t.text "uniform_colors"
    t.integer "view_count", default: 0
    t.integer "application_count", default: 0
    t.decimal "completion_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.decimal "revenue_generated", precision: 10, scale: 2, default: "0.0"
    t.decimal "platform_fee", precision: 10, scale: 2, default: "0.0"
    t.decimal "host_payout", precision: 10, scale: 2, default: "0.0"
    t.boolean "weather_cancelled", default: false
    t.integer "no_show_count", default: 0
    t.integer "final_player_count"
    t.datetime "closed_at"
    t.decimal "actual_revenue", precision: 10, scale: 2
    t.decimal "actual_platform_fee", precision: 10, scale: 2
    t.decimal "actual_host_revenue", precision: 10, scale: 2
    t.boolean "is_partial_settlement", default: false
    t.datetime "settlement_notified_at"
    t.index ["application_count"], name: "index_games_on_application_count"
    t.index ["average_rating"], name: "index_games_on_average_rating"
    t.index ["cancelled_at"], name: "index_games_on_cancelled_at"
    t.index ["cancelled_by_user_id"], name: "index_games_on_cancelled_by_user_id"
    t.index ["city", "district", "scheduled_at"], name: "index_games_on_city_and_district_and_scheduled_at"
    t.index ["city", "district"], name: "index_games_on_city_and_district"
    t.index ["completion_rate"], name: "index_games_on_completion_rate"
    t.index ["court_id"], name: "index_games_on_court_id"
    t.index ["fee"], name: "index_games_on_fee"
    t.index ["game_id"], name: "index_games_on_game_id", unique: true
    t.index ["game_type"], name: "index_games_on_game_type"
    t.index ["host_payment_transferred_at"], name: "index_games_on_host_payment_transferred_at"
    t.index ["is_recurring"], name: "index_games_on_is_recurring"
    t.index ["level"], name: "index_games_on_level"
    t.index ["organizer_id", "scheduled_at"], name: "index_games_on_organizer_id_and_scheduled_at"
    t.index ["organizer_id"], name: "index_games_on_organizer_id"
    t.index ["parent_game_id"], name: "index_games_on_parent_game_id"
    t.index ["payment_deadline_hours"], name: "index_games_on_payment_deadline_hours"
    t.index ["requires_payment"], name: "index_games_on_requires_payment"
    t.index ["revenue_generated"], name: "index_games_on_revenue_generated"
    t.index ["scheduled_at"], name: "index_games_on_scheduled_at"
    t.index ["status", "scheduled_at"], name: "index_games_on_status_and_scheduled_at"
    t.index ["status"], name: "index_games_on_status"
    t.index ["view_count"], name: "index_games_on_view_count"
    t.index ["waitlist_enabled"], name: "index_games_on_waitlist_enabled"
    t.index ["weather_cancelled"], name: "index_games_on_weather_cancelled"
    t.check_constraint "fee >= 0", name: "games_fee_positive_check"
    t.check_constraint "max_players > 0", name: "games_max_players_positive_check"
    t.check_constraint "max_waitlist >= 0", name: "games_max_waitlist_positive_check"
    t.check_constraint "payment_deadline_hours > 0", name: "games_payment_deadline_hours_positive_check"
    t.check_constraint "platform_fee_percentage >= 0 AND platform_fee_percentage <= 100", name: "games_platform_fee_percentage_valid_check"
    t.check_constraint "recurring_pattern IN ('daily', 'weekly', 'monthly', 'custom') OR recurring_pattern IS NULL", name: "games_recurring_pattern_check"
  end

  create_table "locations", force: :cascade do |t|
    t.string "city", null: false
    t.string "district", null: false
    t.string "full_name", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "district"], name: "index_locations_on_city_and_district", unique: true
    t.index ["city"], name: "index_locations_on_city"
    t.index ["full_name"], name: "index_locations_on_full_name"
  end

  create_table "match_player_stats", force: :cascade do |t|
    t.integer "tournament_match_id", null: false
    t.integer "user_id", null: false
    t.integer "tournament_team_id", null: false
    t.string "team_type"
    t.integer "minutes_played", default: 0
    t.boolean "starter", default: false
    t.integer "points", default: 0
    t.integer "field_goals_made", default: 0
    t.integer "field_goals_attempted", default: 0
    t.integer "three_pointers_made", default: 0
    t.integer "three_pointers_attempted", default: 0
    t.integer "free_throws_made", default: 0
    t.integer "free_throws_attempted", default: 0
    t.integer "offensive_rebounds", default: 0
    t.integer "defensive_rebounds", default: 0
    t.integer "total_rebounds", default: 0
    t.integer "assists", default: 0
    t.integer "steals", default: 0
    t.integer "blocks", default: 0
    t.integer "turnovers", default: 0
    t.integer "personal_fouls", default: 0
    t.decimal "plus_minus", precision: 5, scale: 1, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["points"], name: "index_match_player_stats_on_points"
    t.index ["team_type"], name: "index_match_player_stats_on_team_type"
    t.index ["tournament_match_id", "user_id"], name: "index_match_player_stats_on_tournament_match_id_and_user_id", unique: true
    t.index ["tournament_match_id"], name: "index_match_player_stats_on_tournament_match_id"
    t.index ["tournament_team_id"], name: "index_match_player_stats_on_tournament_team_id"
    t.index ["user_id"], name: "index_match_player_stats_on_user_id"
  end

  create_table "match_pool_participants", force: :cascade do |t|
    t.integer "match_pool_id", null: false
    t.integer "user_id", null: false
    t.string "status", default: "waiting"
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_pool_id", "user_id"], name: "index_match_pool_participants_on_match_pool_id_and_user_id", unique: true
    t.index ["match_pool_id"], name: "index_match_pool_participants_on_match_pool_id"
    t.index ["user_id"], name: "index_match_pool_participants_on_user_id"
  end

  create_table "match_pools", force: :cascade do |t|
    t.string "city", null: false
    t.string "district"
    t.datetime "match_time", null: false
    t.integer "skill_level"
    t.integer "current_players", default: 0
    t.integer "min_players", default: 6
    t.integer "max_players", default: 10
    t.string "status", default: "forming"
    t.string "game_type", default: "pickup"
    t.integer "created_game_id"
    t.json "player_ids", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "district"], name: "index_match_pools_on_city_and_district"
    t.index ["created_game_id"], name: "index_match_pools_on_created_game_id"
    t.index ["match_time"], name: "index_match_pools_on_match_time"
    t.index ["status"], name: "index_match_pools_on_status"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "notification_type", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.json "data"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 1, null: false
    t.datetime "read_at"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["priority"], name: "index_notifications_on_priority"
    t.index ["status"], name: "index_notifications_on_status"
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at"
    t.index ["user_id", "status"], name: "index_notifications_on_user_id_and_status"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "outdoor_courts", force: :cascade do |t|
    t.string "title", null: false
    t.string "image1", null: false
    t.string "image2", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "address", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_outdoor_courts_on_created_at"
    t.index ["latitude", "longitude"], name: "index_outdoor_courts_on_latitude_and_longitude"
    t.index ["user_id", "created_at"], name: "index_outdoor_courts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_outdoor_courts_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "game_application_id", null: false
    t.decimal "amount"
    t.string "status"
    t.string "payment_method"
    t.text "bdr_account_info"
    t.datetime "paid_at"
    t.datetime "transferred_to_host_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "toss_payment_key"
    t.string "toss_order_id"
    t.string "payment_type", default: "participation_fee"
    t.text "refund_reason"
    t.datetime "refunded_at"
    t.decimal "refund_amount", precision: 10, scale: 2
    t.string "transaction_id"
    t.text "payment_gateway_response"
    t.text "failure_reason"
    t.integer "retry_count", default: 0
    t.integer "processed_by_user_id"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.text "admin_notes"
    t.integer "processing_time"
    t.decimal "fee_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "net_amount", precision: 10, scale: 2, default: "0.0"
    t.string "currency", default: "KRW"
    t.string "toss_refund_id"
    t.string "refund_status"
    t.index ["created_at"], name: "index_payments_on_created_at"
    t.index ["created_by_user_id"], name: "index_payments_on_created_by_user_id"
    t.index ["currency"], name: "index_payments_on_currency"
    t.index ["fee_amount"], name: "index_payments_on_fee_amount"
    t.index ["game_application_id", "status"], name: "index_payments_on_game_application_id_and_status"
    t.index ["game_application_id"], name: "index_payments_on_game_application_id"
    t.index ["net_amount"], name: "index_payments_on_net_amount"
    t.index ["paid_at"], name: "index_payments_on_paid_at"
    t.index ["payment_type"], name: "index_payments_on_payment_type"
    t.index ["processed_by_user_id"], name: "index_payments_on_processed_by_user_id"
    t.index ["processing_time"], name: "index_payments_on_processing_time"
    t.index ["refunded_at"], name: "index_payments_on_refunded_at"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["toss_order_id"], name: "index_payments_on_toss_order_id"
    t.index ["toss_payment_key"], name: "index_payments_on_toss_payment_key"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id"
    t.index ["transferred_to_host_at"], name: "index_payments_on_transferred_to_host_at"
    t.index ["updated_by_user_id"], name: "index_payments_on_updated_by_user_id"
    t.check_constraint "payment_type IN ('participation_fee', 'refund', 'transfer_to_host')", name: "payments_payment_type_check"
    t.check_constraint "refund_amount >= 0", name: "payments_refund_amount_positive_check"
    t.check_constraint "retry_count >= 0", name: "payments_retry_count_positive_check"
    t.check_constraint "status IN ('pending', 'paid', 'transferred', 'refunded')", name: "payments_status_check"
  end

  create_table "play_styles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "assist_percentage", default: 0
    t.integer "three_point_percentage", default: 0
    t.integer "defense_percentage", default: 0
    t.integer "rebound_percentage", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_play_styles_on_user_id"
  end

  create_table "player_evaluations", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "evaluator_type", null: false
    t.integer "evaluator_id", null: false
    t.integer "evaluated_user_id", null: false
    t.integer "skill_level"
    t.integer "teamwork"
    t.integer "manner"
    t.boolean "memorable"
    t.text "comment"
    t.datetime "evaluated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evaluated_user_id"], name: "index_player_evaluations_on_evaluated_user_id"
    t.index ["evaluator_type", "evaluator_id"], name: "index_player_evaluations_on_evaluator"
    t.index ["game_id", "evaluated_at"], name: "index_player_evaluations_on_game_id_and_evaluated_at"
    t.index ["game_id", "evaluator_id", "evaluator_type", "evaluated_user_id"], name: "unique_evaluation_index", unique: true
    t.index ["game_id"], name: "index_player_evaluations_on_game_id"
  end

  create_table "player_stats", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_id", null: false
    t.integer "game_result_id"
    t.integer "minutes_played", default: 0
    t.integer "points", default: 0
    t.integer "field_goals_made", default: 0
    t.integer "field_goals_attempted", default: 0
    t.integer "three_pointers_made", default: 0
    t.integer "three_pointers_attempted", default: 0
    t.integer "free_throws_made", default: 0
    t.integer "free_throws_attempted", default: 0
    t.integer "offensive_rebounds", default: 0
    t.integer "defensive_rebounds", default: 0
    t.integer "total_rebounds", default: 0
    t.integer "assists", default: 0
    t.integer "steals", default: 0
    t.integer "blocks", default: 0
    t.integer "turnovers", default: 0
    t.integer "personal_fouls", default: 0
    t.decimal "plus_minus", precision: 5, scale: 1, default: "0.0"
    t.decimal "player_efficiency_rating", precision: 5, scale: 2, default: "0.0"
    t.decimal "true_shooting_percentage", precision: 5, scale: 2, default: "0.0"
    t.decimal "effective_field_goal_percentage", precision: 5, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_player_stats_on_game_id"
    t.index ["game_result_id"], name: "index_player_stats_on_game_result_id"
    t.index ["points"], name: "index_player_stats_on_points"
    t.index ["user_id", "created_at"], name: "index_player_stats_on_user_id_and_created_at"
    t.index ["user_id", "game_id"], name: "index_player_stats_on_user_id_and_game_id", unique: true
    t.index ["user_id"], name: "index_player_stats_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.string "category", null: false
    t.string "image1"
    t.string "image2"
    t.integer "views_count", default: 0
    t.integer "comments_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "created_at"], name: "index_posts_on_category_and_created_at"
    t.index ["category"], name: "index_posts_on_category"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
    t.index ["views_count"], name: "index_posts_on_views_count"
  end

  create_table "premium_subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "plan_type", null: false
    t.string "payment_key", null: false
    t.string "order_id", null: false
    t.integer "amount", null: false
    t.string "status", default: "active", null: false
    t.datetime "started_at", null: false
    t.datetime "cancelled_at"
    t.datetime "refunded_at"
    t.integer "refund_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_premium_subscriptions_on_order_id", unique: true
    t.index ["payment_key"], name: "index_premium_subscriptions_on_payment_key", unique: true
    t.index ["plan_type"], name: "index_premium_subscriptions_on_plan_type"
    t.index ["status"], name: "index_premium_subscriptions_on_status"
    t.index ["user_id"], name: "index_premium_subscriptions_on_user_id"
  end

  create_table "quick_match_histories", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_id"
    t.integer "match_pool_id"
    t.string "match_type"
    t.integer "search_time_seconds"
    t.boolean "successful", default: false
    t.json "search_criteria"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_quick_match_histories_on_game_id"
    t.index ["match_pool_id"], name: "index_quick_match_histories_on_match_pool_id"
    t.index ["successful"], name: "index_quick_match_histories_on_successful"
    t.index ["user_id"], name: "index_quick_match_histories_on_user_id"
  end

  create_table "quick_match_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.json "preferred_times"
    t.json "preferred_locations"
    t.integer "preferred_level_range", default: 1
    t.integer "max_distance_km", default: 10
    t.boolean "auto_match_enabled", default: false
    t.json "preferred_game_types", default: []
    t.integer "min_players", default: 6
    t.integer "max_players", default: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auto_match_enabled"], name: "index_quick_match_preferences_on_auto_match_enabled"
    t.index ["user_id"], name: "index_quick_match_preferences_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_id", null: false
    t.integer "rated_user_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.string "rating_type", default: "player", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_ratings_on_game_id"
    t.index ["rated_user_id", "created_at"], name: "index_ratings_on_rated_user_id_and_created_at"
    t.index ["rated_user_id"], name: "index_ratings_on_rated_user_id"
    t.index ["rating_type"], name: "index_ratings_on_rating_type"
    t.index ["user_id", "game_id", "rated_user_id"], name: "index_ratings_on_user_id_and_game_id_and_rated_user_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "query", null: false
    t.string "schedule"
    t.datetime "last_run"
    t.datetime "next_run"
    t.boolean "active", default: true
    t.json "parameters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_reports_on_active"
    t.index ["name"], name: "index_reports_on_name"
    t.index ["schedule"], name: "index_reports_on_schedule"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "reviewable_type", null: false
    t.integer "reviewable_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable"
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable_type_and_reviewable_id"
    t.index ["user_id", "reviewable_type", "reviewable_id"], name: "index_reviews_on_user_and_reviewable", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "season_averages", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "season_name"
    t.date "season_start"
    t.date "season_end"
    t.integer "games_played", default: 0
    t.integer "games_started", default: 0
    t.integer "wins", default: 0
    t.integer "losses", default: 0
    t.decimal "minutes_per_game", precision: 5, scale: 2, default: "0.0"
    t.decimal "points_per_game", precision: 5, scale: 2, default: "0.0"
    t.decimal "rebounds_per_game", precision: 5, scale: 2, default: "0.0"
    t.decimal "assists_per_game", precision: 5, scale: 2, default: "0.0"
    t.decimal "steals_per_game", precision: 5, scale: 2, default: "0.0"
    t.decimal "blocks_per_game", precision: 5, scale: 2, default: "0.0"
    t.decimal "turnovers_per_game", precision: 5, scale: 2, default: "0.0"
    t.decimal "field_goal_percentage", precision: 5, scale: 2, default: "0.0"
    t.decimal "three_point_percentage", precision: 5, scale: 2, default: "0.0"
    t.decimal "free_throw_percentage", precision: 5, scale: 2, default: "0.0"
    t.decimal "player_efficiency_rating", precision: 5, scale: 2, default: "0.0"
    t.decimal "true_shooting_percentage", precision: 5, scale: 2, default: "0.0"
    t.decimal "usage_rate", precision: 5, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["points_per_game"], name: "index_season_averages_on_points_per_game"
    t.index ["user_id", "season_name"], name: "index_season_averages_on_user_id_and_season_name", unique: true
    t.index ["user_id", "season_start"], name: "index_season_averages_on_user_id_and_season_start"
    t.index ["user_id"], name: "index_season_averages_on_user_id"
  end

  create_table "suggestions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.string "status", default: "pending", null: false
    t.text "admin_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_suggestions_on_created_at"
    t.index ["status"], name: "index_suggestions_on_status"
    t.index ["user_id"], name: "index_suggestions_on_user_id"
  end

  create_table "system_settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.text "description"
    t.string "category", null: false
    t.boolean "editable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_system_settings_on_category"
    t.index ["key"], name: "index_system_settings_on_key", unique: true
  end

  create_table "team_members", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "user_id", null: false
    t.string "role", default: "player"
    t.integer "jersey_number"
    t.boolean "is_active", default: true
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role"], name: "index_team_members_on_role"
    t.index ["team_id", "jersey_number"], name: "index_team_members_on_team_id_and_jersey_number", unique: true
    t.index ["team_id", "user_id"], name: "index_team_members_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.integer "captain_id", null: false
    t.text "description"
    t.string "logo_url"
    t.string "home_court"
    t.string "city"
    t.string "district"
    t.boolean "is_active", default: true
    t.integer "wins", default: 0
    t.integer "losses", default: 0
    t.integer "tournaments_participated", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["captain_id", "name"], name: "index_teams_on_captain_id_and_name", unique: true
    t.index ["captain_id"], name: "index_teams_on_captain_id"
    t.index ["is_active"], name: "index_teams_on_is_active"
  end

  create_table "tournament_automations", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.string "automation_type"
    t.string "status", default: "scheduled"
    t.json "configuration"
    t.datetime "scheduled_at"
    t.datetime "executed_at"
    t.text "execution_log"
    t.integer "retry_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["automation_type"], name: "index_tournament_automations_on_automation_type"
    t.index ["scheduled_at"], name: "index_tournament_automations_on_scheduled_at"
    t.index ["status"], name: "index_tournament_automations_on_status"
    t.index ["tournament_id"], name: "index_tournament_automations_on_tournament_id"
  end

  create_table "tournament_budgets", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.string "category"
    t.string "description"
    t.decimal "amount", precision: 10, scale: 2
    t.boolean "is_income", default: false
    t.datetime "transaction_date"
    t.string "receipt_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_tournament_budgets_on_category"
    t.index ["tournament_id"], name: "index_tournament_budgets_on_tournament_id"
  end

  create_table "tournament_check_ins", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.integer "user_id", null: false
    t.integer "tournament_team_id"
    t.string "role"
    t.string "qr_code"
    t.datetime "checked_in_at"
    t.string "device_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["checked_in_at"], name: "index_tournament_check_ins_on_checked_in_at"
    t.index ["qr_code"], name: "index_tournament_check_ins_on_qr_code"
    t.index ["tournament_id"], name: "index_tournament_check_ins_on_tournament_id"
    t.index ["tournament_team_id"], name: "index_tournament_check_ins_on_tournament_team_id"
    t.index ["user_id"], name: "index_tournament_check_ins_on_user_id"
  end

  create_table "tournament_checklists", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.string "phase"
    t.string "task_name", null: false
    t.text "description"
    t.boolean "completed", default: false
    t.datetime "completed_at"
    t.integer "priority", default: 0
    t.boolean "automated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed"], name: "index_tournament_checklists_on_completed"
    t.index ["phase"], name: "index_tournament_checklists_on_phase"
    t.index ["tournament_id", "phase"], name: "index_tournament_checklists_on_tournament_id_and_phase"
    t.index ["tournament_id"], name: "index_tournament_checklists_on_tournament_id"
  end

  create_table "tournament_feedback", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.integer "user_id", null: false
    t.integer "overall_rating"
    t.text "comment"
    t.json "ratings"
    t.boolean "would_participate_again", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_tournament_feedback_on_tournament_id"
    t.index ["user_id"], name: "index_tournament_feedback_on_user_id"
  end

  create_table "tournament_live_updates", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.integer "tournament_match_id"
    t.integer "user_id", null: false
    t.string "update_type"
    t.json "data"
    t.boolean "is_official", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_tournament_live_updates_on_tournament_id"
    t.index ["tournament_match_id"], name: "index_tournament_live_updates_on_tournament_match_id"
    t.index ["update_type"], name: "index_tournament_live_updates_on_update_type"
    t.index ["user_id"], name: "index_tournament_live_updates_on_user_id"
  end

  create_table "tournament_marketing_campaigns", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.string "campaign_type"
    t.string "channel"
    t.integer "recipients_count"
    t.integer "opens_count", default: 0
    t.integer "clicks_count", default: 0
    t.datetime "sent_at"
    t.json "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_type"], name: "index_tournament_marketing_campaigns_on_campaign_type"
    t.index ["tournament_id"], name: "index_tournament_marketing_campaigns_on_tournament_id"
  end

  create_table "tournament_matches", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.string "round"
    t.integer "match_number"
    t.datetime "scheduled_at"
    t.string "court_name"
    t.string "status", default: "scheduled"
    t.integer "home_score"
    t.integer "away_score"
    t.integer "winner_team_id"
    t.text "match_notes"
    t.string "referee_names"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "quarter_scores"
    t.json "overtime_scores"
    t.integer "game_duration"
    t.string "round_name"
    t.string "group"
    t.integer "court_number"
    t.index ["away_team_id"], name: "index_tournament_matches_on_away_team_id"
    t.index ["home_team_id"], name: "index_tournament_matches_on_home_team_id"
    t.index ["status"], name: "index_tournament_matches_on_status"
    t.index ["tournament_id", "round"], name: "index_tournament_matches_on_tournament_id_and_round"
    t.index ["tournament_id", "scheduled_at"], name: "index_tournament_matches_on_tournament_id_and_scheduled_at"
    t.index ["tournament_id"], name: "index_tournament_matches_on_tournament_id"
    t.index ["winner_team_id"], name: "index_tournament_matches_on_winner_team_id"
  end

  create_table "tournament_media", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.integer "user_id", null: false
    t.string "media_type"
    t.string "title"
    t.text "description"
    t.string "file_url"
    t.json "metadata"
    t.integer "views_count", default: 0
    t.integer "likes_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_type"], name: "index_tournament_media_on_media_type"
    t.index ["tournament_id"], name: "index_tournament_media_on_tournament_id"
    t.index ["user_id"], name: "index_tournament_media_on_user_id"
  end

  create_table "tournament_players", force: :cascade do |t|
    t.integer "tournament_team_id", null: false
    t.integer "user_id", null: false
    t.string "position"
    t.integer "jersey_number"
    t.boolean "is_starter", default: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_team_id", "jersey_number"], name: "idx_on_tournament_team_id_jersey_number_5ab8d46b50", unique: true
    t.index ["tournament_team_id", "user_id"], name: "index_tournament_players_on_tournament_team_id_and_user_id", unique: true
    t.index ["tournament_team_id"], name: "index_tournament_players_on_tournament_team_id"
    t.index ["user_id"], name: "index_tournament_players_on_user_id"
  end

  create_table "tournament_share_links", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.string "share_type"
    t.string "short_code"
    t.string "full_url"
    t.integer "click_count", default: 0
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["share_type"], name: "index_tournament_share_links_on_share_type"
    t.index ["short_code"], name: "index_tournament_share_links_on_short_code"
    t.index ["tournament_id"], name: "index_tournament_share_links_on_tournament_id"
  end

  create_table "tournament_teams", force: :cascade do |t|
    t.integer "tournament_id", null: false
    t.string "team_name", null: false
    t.integer "captain_id"
    t.string "status", default: "pending"
    t.text "roster"
    t.string "contact_phone"
    t.string "contact_email"
    t.text "notes"
    t.datetime "registered_at"
    t.datetime "approved_at"
    t.boolean "payment_completed", default: false
    t.datetime "payment_completed_at"
    t.integer "seed_number"
    t.integer "final_rank"
    t.integer "wins", default: 0
    t.integer "losses", default: 0
    t.integer "points_for", default: 0
    t.integer "points_against", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "qr_token"
    t.boolean "checked_in", default: false
    t.datetime "checked_in_at"
    t.integer "team_id"
    t.index ["captain_id"], name: "index_tournament_teams_on_captain_id"
    t.index ["qr_token"], name: "index_tournament_teams_on_qr_token", unique: true
    t.index ["team_id"], name: "index_tournament_teams_on_team_id"
    t.index ["tournament_id", "status"], name: "index_tournament_teams_on_tournament_id_and_status"
    t.index ["tournament_id", "team_name"], name: "index_tournament_teams_on_tournament_id_and_team_name", unique: true
    t.index ["tournament_id"], name: "index_tournament_teams_on_tournament_id"
  end

  create_table "tournament_templates", force: :cascade do |t|
    t.string "name", null: false
    t.string "template_type"
    t.integer "default_team_count"
    t.integer "estimated_duration_hours"
    t.string "default_format"
    t.text "default_rules"
    t.boolean "is_popular", default: false
    t.integer "usage_count", default: 0
    t.string "category"
    t.boolean "is_premium_only", default: false
    t.json "configuration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_popular"], name: "index_tournament_templates_on_is_popular"
    t.index ["template_type"], name: "index_tournament_templates_on_template_type"
  end

  create_table "tournament_wizards", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "tournament_id"
    t.string "step", default: "template_selection"
    t.json "wizard_data", default: {}
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed"], name: "index_tournament_wizards_on_completed"
    t.index ["step"], name: "index_tournament_wizards_on_step"
    t.index ["tournament_id"], name: "index_tournament_wizards_on_tournament_id"
    t.index ["user_id"], name: "index_tournament_wizards_on_user_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "tournament_type"
    t.string "status", default: "draft"
    t.datetime "registration_start_at"
    t.datetime "registration_end_at"
    t.datetime "tournament_start_at"
    t.datetime "tournament_end_at"
    t.integer "min_teams", default: 4
    t.integer "max_teams", default: 16
    t.integer "players_per_team", default: 5
    t.decimal "entry_fee", precision: 10, scale: 2, default: "0.0"
    t.decimal "prize_pool", precision: 10, scale: 2, default: "0.0"
    t.string "location_name"
    t.string "location_address"
    t.decimal "location_latitude", precision: 10, scale: 6
    t.decimal "location_longitude", precision: 10, scale: 6
    t.integer "organizer_id"
    t.string "contact_phone"
    t.string "contact_email"
    t.text "rules"
    t.text "prizes"
    t.string "sponsor_names"
    t.string "poster_image"
    t.string "banner_image"
    t.boolean "featured", default: false
    t.integer "view_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tournament_code"
    t.string "venue"
    t.text "contact_info"
    t.boolean "is_featured", default: false
    t.text "prize_info"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.text "approval_notes"
    t.text "rejection_reason"
    t.boolean "is_official", default: false
    t.boolean "created_by_premium_user", default: false
    t.string "template_used"
    t.boolean "ai_poster_generated", default: false
    t.string "poster_style"
    t.string "poster_image_url"
    t.boolean "auto_bracket_generated", default: false
    t.boolean "live_streaming_enabled", default: false
    t.boolean "auto_notification_enabled", default: true
    t.decimal "platform_fee_percentage", precision: 5, scale: 2, default: "5.0"
    t.decimal "actual_platform_fee", precision: 10, scale: 2
    t.decimal "total_revenue", precision: 10, scale: 2
    t.string "settlement_status"
    t.datetime "settlement_completed_at"
    t.string "template_type"
    t.boolean "is_quick_tournament", default: false
    t.boolean "auto_bracket_generation", default: true
    t.boolean "auto_score_calculation", default: true
    t.boolean "mobile_optimized", default: true
    t.json "share_settings", default: {}
    t.json "notification_settings", default: {}
    t.string "poster_template_id"
    t.json "poster_settings", default: {}
    t.json "budget_settings", default: {}
    t.json "special_events", default: []
    t.json "prizes_info", default: {}
    t.string "checkin_qr_code"
    t.text "organizer_notes"
    t.text "post_event_summary"
    t.integer "images_count", default: 0
    t.integer "main_image_position", default: 0
    t.integer "tournament_template_id"
    t.integer "progress_percentage", default: 0
    t.string "current_round"
    t.json "quick_action_buttons"
    t.boolean "brackets_published", default: false
    t.datetime "brackets_published_at"
    t.datetime "paused_at"
    t.index ["created_by_premium_user"], name: "index_tournaments_on_created_by_premium_user"
    t.index ["featured"], name: "index_tournaments_on_featured"
    t.index ["is_official"], name: "index_tournaments_on_is_official"
    t.index ["is_quick_tournament"], name: "index_tournaments_on_is_quick_tournament"
    t.index ["organizer_id"], name: "index_tournaments_on_organizer_id"
    t.index ["registration_start_at"], name: "index_tournaments_on_registration_start_at"
    t.index ["settlement_status"], name: "index_tournaments_on_settlement_status"
    t.index ["status", "tournament_start_at"], name: "index_tournaments_on_status_and_tournament_start_at"
    t.index ["status"], name: "index_tournaments_on_status"
    t.index ["template_type"], name: "index_tournaments_on_template_type"
    t.index ["tournament_code"], name: "index_tournaments_on_tournament_code", unique: true
    t.index ["tournament_start_at"], name: "index_tournaments_on_tournament_start_at"
    t.index ["tournament_template_id"], name: "index_tournaments_on_tournament_template_id"
  end

  create_table "user_achievements", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "achievement_id", null: false
    t.datetime "earned_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["earned_at"], name: "index_user_achievements_on_earned_at"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "user_cancellations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "cancellation_count", default: 0
    t.datetime "last_cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "weekly_cancellation_count"
    t.datetime "first_weekly_cancelled_at"
    t.index ["user_id"], name: "index_user_cancellations_on_user_id"
  end

  create_table "user_points", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "points", default: 0, null: false
    t.string "description", null: false
    t.string "transaction_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_user_points_on_created_at"
    t.index ["transaction_type"], name: "index_user_points_on_transaction_type"
    t.index ["user_id"], name: "index_user_points_on_user_id"
  end

  create_table "user_rating_histories", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "rating_before", precision: 5, scale: 3
    t.decimal "rating_after", precision: 5, scale: 3
    t.decimal "rating_change", precision: 5, scale: 3
    t.string "change_reason"
    t.integer "game_id", null: false
    t.integer "evaluation_count"
    t.integer "positive_count"
    t.integer "negative_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_user_rating_histories_on_game_id"
    t.index ["user_id", "created_at"], name: "index_user_rating_histories_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_user_rating_histories_on_user_id"
  end

  create_table "user_stats", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "rating", precision: 3, scale: 2, default: "0.0"
    t.integer "wins", default: 0
    t.integer "losses", default: 0
    t.integer "games_played", default: 0
    t.integer "mvp_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_stats_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "old_position"
    t.integer "old_skill_level"
    t.string "old_location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nickname"
    t.string "real_name"
    t.integer "height"
    t.integer "weight"
    t.text "positions"
    t.string "city"
    t.string "district"
    t.string "team_name"
    t.text "bio"
    t.boolean "profile_completed", default: false
    t.date "birth_date"
    t.integer "basketball_experience", default: 0
    t.string "bank_name"
    t.string "account_number"
    t.string "account_holder"
    t.boolean "email_notifications", default: true
    t.boolean "sms_notifications", default: true
    t.boolean "push_notifications", default: true
    t.text "notification_preferences"
    t.string "timezone", default: "Asia/Seoul"
    t.datetime "last_login_at"
    t.integer "login_count", default: 0
    t.string "status", default: "active"
    t.datetime "suspended_at"
    t.text "suspension_reason"
    t.boolean "admin", default: false, null: false
    t.datetime "last_activity_at"
    t.string "registration_source"
    t.string "referrer_url"
    t.boolean "marketing_consent", default: false
    t.integer "profile_views", default: 0
    t.integer "total_games_hosted", default: 0
    t.integer "total_games_participated", default: 0
    t.decimal "total_revenue", precision: 10, scale: 2, default: "0.0"
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.decimal "reliability_score", precision: 3, scale: 2, default: "5.0"
    t.integer "total_points", default: 0
    t.boolean "is_premium", default: false
    t.datetime "premium_expires_at"
    t.string "premium_type"
    t.decimal "evaluation_rating", precision: 5, scale: 3, default: "50.0"
    t.boolean "is_host", default: false, null: false
    t.integer "rating_count", default: 0
    t.integer "tournaments_hosted_count", default: 0
    t.decimal "tournament_host_rating", precision: 3, scale: 2
    t.boolean "can_create_tournaments", default: false
    t.integer "max_concurrent_tournaments", default: 0
    t.integer "quick_match_priority", default: 0
    t.datetime "last_quick_match_at"
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["average_rating"], name: "index_users_on_average_rating"
    t.index ["bank_name"], name: "index_users_on_bank_name"
    t.index ["can_create_tournaments"], name: "index_users_on_can_create_tournaments"
    t.index ["city", "district", "created_at"], name: "index_users_on_city_district_created_at"
    t.index ["city", "district"], name: "index_users_on_city_and_district"
    t.index ["city"], name: "index_users_on_city"
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["district"], name: "index_users_on_district"
    t.index ["email_notifications"], name: "index_users_on_email_notifications"
    t.index ["is_host"], name: "index_users_on_is_host"
    t.index ["is_premium"], name: "index_users_on_is_premium"
    t.index ["last_activity_at"], name: "index_users_on_last_activity_at"
    t.index ["last_login_at"], name: "index_users_on_last_login_at"
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["premium_expires_at"], name: "index_users_on_premium_expires_at"
    t.index ["profile_completed"], name: "index_users_on_profile_completed"
    t.index ["quick_match_priority"], name: "index_users_on_quick_match_priority"
    t.index ["rating_count"], name: "index_users_on_rating_count"
    t.index ["registration_source"], name: "index_users_on_registration_source"
    t.index ["reliability_score"], name: "index_users_on_reliability_score"
    t.index ["status"], name: "index_users_on_status"
    t.index ["suspended_at"], name: "index_users_on_suspended_at"
    t.index ["total_games_hosted"], name: "index_users_on_total_games_hosted"
    t.index ["total_games_participated"], name: "index_users_on_total_games_participated"
    t.check_constraint "login_count >= 0", name: "users_login_count_positive_check"
    t.check_constraint "status IN ('active', 'suspended', 'inactive', 'banned')", name: "users_status_check"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "users"
  add_foreign_key "admin_logs", "users"
  add_foreign_key "ai_poster_generations", "tournaments"
  add_foreign_key "billing_keys", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "court_activities", "courts"
  add_foreign_key "court_activities", "users"
  add_foreign_key "court_visits", "courts"
  add_foreign_key "court_visits", "users"
  add_foreign_key "evaluation_deadlines", "games"
  add_foreign_key "game_applications", "games"
  add_foreign_key "game_applications", "users"
  add_foreign_key "game_applications", "users", column: "status_changed_by_user_id", on_delete: :nullify
  add_foreign_key "game_participations", "games"
  add_foreign_key "game_participations", "users"
  add_foreign_key "game_results", "games"
  add_foreign_key "game_results", "users"
  add_foreign_key "games", "courts"
  add_foreign_key "games", "games", column: "parent_game_id", on_delete: :cascade
  add_foreign_key "games", "users", column: "cancelled_by_user_id", on_delete: :nullify
  add_foreign_key "games", "users", column: "organizer_id", on_delete: :cascade
  add_foreign_key "match_player_stats", "tournament_matches"
  add_foreign_key "match_player_stats", "tournament_teams"
  add_foreign_key "match_player_stats", "users"
  add_foreign_key "match_pool_participants", "match_pools"
  add_foreign_key "match_pool_participants", "users"
  add_foreign_key "match_pools", "games", column: "created_game_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "outdoor_courts", "users"
  add_foreign_key "payments", "game_applications"
  add_foreign_key "payments", "users", column: "created_by_user_id", on_delete: :nullify
  add_foreign_key "payments", "users", column: "processed_by_user_id", on_delete: :nullify
  add_foreign_key "payments", "users", column: "updated_by_user_id", on_delete: :nullify
  add_foreign_key "play_styles", "users"
  add_foreign_key "player_evaluations", "games"
  add_foreign_key "player_evaluations", "users", column: "evaluated_user_id"
  add_foreign_key "player_stats", "game_results"
  add_foreign_key "player_stats", "games"
  add_foreign_key "player_stats", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "premium_subscriptions", "users"
  add_foreign_key "quick_match_histories", "games"
  add_foreign_key "quick_match_histories", "match_pools"
  add_foreign_key "quick_match_histories", "users"
  add_foreign_key "quick_match_preferences", "users"
  add_foreign_key "ratings", "games"
  add_foreign_key "ratings", "users"
  add_foreign_key "ratings", "users", column: "rated_user_id"
  add_foreign_key "reviews", "users"
  add_foreign_key "season_averages", "users"
  add_foreign_key "suggestions", "users"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users"
  add_foreign_key "teams", "users", column: "captain_id"
  add_foreign_key "tournament_automations", "tournaments"
  add_foreign_key "tournament_budgets", "tournaments"
  add_foreign_key "tournament_check_ins", "tournament_teams"
  add_foreign_key "tournament_check_ins", "tournaments"
  add_foreign_key "tournament_check_ins", "users"
  add_foreign_key "tournament_checklists", "tournaments"
  add_foreign_key "tournament_feedback", "tournaments"
  add_foreign_key "tournament_feedback", "users"
  add_foreign_key "tournament_live_updates", "tournament_matches"
  add_foreign_key "tournament_live_updates", "tournaments"
  add_foreign_key "tournament_live_updates", "users"
  add_foreign_key "tournament_marketing_campaigns", "tournaments"
  add_foreign_key "tournament_matches", "tournament_teams", column: "away_team_id"
  add_foreign_key "tournament_matches", "tournament_teams", column: "home_team_id"
  add_foreign_key "tournament_matches", "tournament_teams", column: "winner_team_id"
  add_foreign_key "tournament_matches", "tournaments"
  add_foreign_key "tournament_media", "tournaments"
  add_foreign_key "tournament_media", "users"
  add_foreign_key "tournament_players", "tournament_teams"
  add_foreign_key "tournament_players", "users"
  add_foreign_key "tournament_share_links", "tournaments"
  add_foreign_key "tournament_teams", "teams"
  add_foreign_key "tournament_teams", "tournaments"
  add_foreign_key "tournament_teams", "users", column: "captain_id"
  add_foreign_key "tournament_wizards", "tournaments"
  add_foreign_key "tournament_wizards", "users"
  add_foreign_key "tournaments", "tournament_templates"
  add_foreign_key "tournaments", "users", column: "organizer_id"
  add_foreign_key "user_achievements", "achievements"
  add_foreign_key "user_achievements", "users"
  add_foreign_key "user_cancellations", "users"
  add_foreign_key "user_points", "users"
  add_foreign_key "user_rating_histories", "games"
  add_foreign_key "user_rating_histories", "users"
  add_foreign_key "user_stats", "users"
end
