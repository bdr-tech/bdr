class ImprovePaymentWorkflow < ActiveRecord::Migration[8.0]
  def change
    # Add missing indexes for better performance
    add_index :game_applications, :status
    add_index :game_applications, [ :game_id, :status ]
    add_index :game_applications, [ :user_id, :status ]
    add_index :game_applications, :payment_confirmed_at
    add_index :game_applications, :final_approved_at

    # Add indexes for payments table
    add_index :payments, :status
    add_index :payments, :paid_at
    add_index :payments, :transferred_to_host_at
    add_index :payments, :toss_payment_key
    add_index :payments, :toss_order_id

    # Add indexes for games table
    add_index :games, :status
    add_index :games, :organizer_id
    add_index :games, :scheduled_at
    add_index :games, :fee
    add_index :games, [ :city, :district, :scheduled_at ]

    # Add indexes for users table
    add_index :users, :bank_name
    add_index :users, [ :city, :district ]

    # Add constraints for data integrity
    add_check_constraint :game_applications,
      "status IN ('pending', 'approved', 'waiting_payment', 'final_approved', 'rejected')",
      name: "game_applications_status_check"

    add_check_constraint :payments,
      "status IN ('pending', 'paid', 'transferred', 'refunded')",
      name: "payments_status_check"

    add_check_constraint :games,
      "fee >= 0",
      name: "games_fee_positive_check"

    add_check_constraint :games,
      "max_players > 0",
      name: "games_max_players_positive_check"

    # Add missing foreign key constraints
    add_foreign_key :games, :users, column: :organizer_id, on_delete: :cascade

    # Add unique constraint for game_id
    # Note: This is already in schema but ensuring it's proper
    remove_index :games, :game_id if index_exists?(:games, :game_id)
    add_index :games, :game_id, unique: true

    # Add composite unique constraint for game applications
    add_index :game_applications, [ :user_id, :game_id ], unique: true, name: "index_game_applications_unique_user_game"
  end
end
