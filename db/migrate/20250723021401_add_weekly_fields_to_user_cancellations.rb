class AddWeeklyFieldsToUserCancellations < ActiveRecord::Migration[8.0]
  def change
    add_column :user_cancellations, :weekly_cancellation_count, :integer
    add_column :user_cancellations, :first_weekly_cancelled_at, :datetime
  end
end
