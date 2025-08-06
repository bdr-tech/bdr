class AddIsActiveToEvaluationDeadlines < ActiveRecord::Migration[8.0]
  def change
    add_column :evaluation_deadlines, :is_active, :boolean, default: true, null: false
  end
end
