class CreateTournamentChecklists < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_checklists do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :phase # day_before, game_day, post_game
      t.string :task_name, null: false
      t.text :description
      t.boolean :completed, default: false
      t.datetime :completed_at
      t.integer :priority, default: 0
      t.boolean :automated, default: false
      
      t.timestamps
    end

    add_index :tournament_checklists, :phase
    add_index :tournament_checklists, :completed
    add_index :tournament_checklists, [:tournament_id, :phase]
  end
end
