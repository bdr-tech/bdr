class CreatePlayerEvaluations < ActiveRecord::Migration[8.0]
  def change
    create_table :player_evaluations do |t|
      t.references :game, null: false, foreign_key: true
      t.references :evaluator, polymorphic: true, null: false
      t.references :evaluated_user, null: false, foreign_key: { to_table: :users }
      t.integer :skill_level
      t.integer :teamwork
      t.integer :manner
      t.boolean :memorable
      t.text :comment
      t.datetime :evaluated_at

      t.timestamps
    end

    add_index :player_evaluations, [ :game_id, :evaluator_id, :evaluator_type, :evaluated_user_id ], unique: true, name: 'unique_evaluation_index'
    add_index :player_evaluations, [ :game_id, :evaluated_at ]
  end
end
