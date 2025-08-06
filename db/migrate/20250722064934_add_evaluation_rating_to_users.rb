class AddEvaluationRatingToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :evaluation_rating, :decimal, precision: 5, scale: 3, default: 50.0
  end
end
