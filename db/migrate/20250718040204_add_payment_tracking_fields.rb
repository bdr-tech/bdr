class AddPaymentTrackingFields < ActiveRecord::Migration[8.0]
  def change
    # Add payment tracking fields to payments table
    add_column :payments, :payment_type, :string, default: 'participation_fee'
    add_column :payments, :refund_reason, :text
    add_column :payments, :refunded_at, :datetime
    add_column :payments, :refund_amount, :decimal, precision: 10, scale: 2
    add_column :payments, :transaction_id, :string
    add_column :payments, :payment_gateway_response, :text
    add_column :payments, :failure_reason, :text
    add_column :payments, :retry_count, :integer, default: 0
    add_column :payments, :processed_by_user_id, :integer

    # Add payment deadline to game applications
    add_column :game_applications, :payment_deadline, :datetime
    add_column :game_applications, :auto_rejected_at, :datetime
    add_column :game_applications, :rejection_reason, :text

    # Add payment-related fields to games
    add_column :games, :payment_deadline_hours, :integer, default: 24
    add_column :games, :auto_approve_applications, :boolean, default: false
    add_column :games, :requires_payment, :boolean, default: true
    add_column :games, :payment_instructions, :text

    # Add host payment tracking
    add_column :games, :host_payment_transferred_at, :datetime
    add_column :games, :host_payment_amount, :decimal, precision: 10, scale: 2
    add_column :games, :platform_fee_amount, :decimal, precision: 10, scale: 2
    add_column :games, :platform_fee_percentage, :decimal, precision: 5, scale: 2, default: 5.0

    # Add indexes for new fields
    add_index :payments, :payment_type
    add_index :payments, :refunded_at
    add_index :payments, :transaction_id
    add_index :payments, :processed_by_user_id

    add_index :game_applications, :payment_deadline
    add_index :game_applications, :auto_rejected_at

    add_index :games, :payment_deadline_hours
    add_index :games, :requires_payment
    add_index :games, :host_payment_transferred_at

    # Add foreign key for processed_by_user_id
    add_foreign_key :payments, :users, column: :processed_by_user_id, on_delete: :nullify

    # Add check constraints
    add_check_constraint :payments,
      "payment_type IN ('participation_fee', 'refund', 'transfer_to_host')",
      name: "payments_payment_type_check"

    add_check_constraint :payments,
      "refund_amount >= 0",
      name: "payments_refund_amount_positive_check"

    add_check_constraint :payments,
      "retry_count >= 0",
      name: "payments_retry_count_positive_check"

    add_check_constraint :games,
      "payment_deadline_hours > 0",
      name: "games_payment_deadline_hours_positive_check"

    add_check_constraint :games,
      "platform_fee_percentage >= 0 AND platform_fee_percentage <= 100",
      name: "games_platform_fee_percentage_valid_check"
  end
end
