class CreateEvaluationDeadlines < ActiveRecord::Migration[8.0]
  def change
    create_table :evaluation_deadlines do |t|
      t.references :game, null: false, foreign_key: true
      t.datetime :deadline

      t.timestamps
    end
  end
end
