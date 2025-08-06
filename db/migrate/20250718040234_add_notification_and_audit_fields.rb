class AddNotificationAndAuditFields < ActiveRecord::Migration[8.0]
  def change
    # Add notification preferences to users
    add_column :users, :email_notifications, :boolean, default: true
    add_column :users, :sms_notifications, :boolean, default: true
    add_column :users, :push_notifications, :boolean, default: true
    add_column :users, :notification_preferences, :text
    add_column :users, :timezone, :string, default: 'Asia/Seoul'
    add_column :users, :last_login_at, :datetime
    add_column :users, :login_count, :integer, default: 0
    add_column :users, :status, :string, default: 'active'
    add_column :users, :suspended_at, :datetime
    add_column :users, :suspension_reason, :text

    # Add audit trail fields to key tables
    add_column :game_applications, :status_changed_by_user_id, :integer
    add_column :game_applications, :status_change_reason, :text
    add_column :game_applications, :host_notes, :text
    add_column :game_applications, :guest_notes, :text

    add_column :payments, :created_by_user_id, :integer
    add_column :payments, :updated_by_user_id, :integer
    add_column :payments, :admin_notes, :text

    add_column :games, :cancelled_at, :datetime
    add_column :games, :cancelled_by_user_id, :integer
    add_column :games, :cancellation_reason, :text
    add_column :games, :is_recurring, :boolean, default: false
    add_column :games, :recurring_pattern, :string
    add_column :games, :parent_game_id, :integer
    add_column :games, :max_waitlist, :integer, default: 0
    add_column :games, :waitlist_enabled, :boolean, default: false

    # Add communication tracking
    add_column :game_applications, :reminder_sent_at, :datetime
    add_column :game_applications, :reminder_count, :integer, default: 0
    add_column :game_applications, :last_contacted_at, :datetime

    # Add indexes for new fields
    add_index :users, :email_notifications
    add_index :users, :status
    add_index :users, :last_login_at
    add_index :users, :suspended_at

    add_index :game_applications, :status_changed_by_user_id
    add_index :game_applications, :reminder_sent_at
    add_index :game_applications, :last_contacted_at

    add_index :payments, :created_by_user_id
    add_index :payments, :updated_by_user_id

    add_index :games, :cancelled_at
    add_index :games, :cancelled_by_user_id
    add_index :games, :parent_game_id
    add_index :games, :is_recurring
    add_index :games, :waitlist_enabled

    # Add foreign key constraints
    add_foreign_key :game_applications, :users, column: :status_changed_by_user_id, on_delete: :nullify
    add_foreign_key :payments, :users, column: :created_by_user_id, on_delete: :nullify
    add_foreign_key :payments, :users, column: :updated_by_user_id, on_delete: :nullify
    add_foreign_key :games, :users, column: :cancelled_by_user_id, on_delete: :nullify
    add_foreign_key :games, :games, column: :parent_game_id, on_delete: :cascade

    # Add check constraints
    add_check_constraint :users,
      "status IN ('active', 'suspended', 'inactive', 'banned')",
      name: "users_status_check"

    add_check_constraint :users,
      "login_count >= 0",
      name: "users_login_count_positive_check"

    add_check_constraint :game_applications,
      "reminder_count >= 0",
      name: "game_applications_reminder_count_positive_check"

    add_check_constraint :games,
      "max_waitlist >= 0",
      name: "games_max_waitlist_positive_check"

    add_check_constraint :games,
      "recurring_pattern IN ('daily', 'weekly', 'monthly', 'custom') OR recurring_pattern IS NULL",
      name: "games_recurring_pattern_check"
  end
end
