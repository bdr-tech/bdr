class CreateGameApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :game_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.string :status
      t.datetime :applied_at
      t.datetime :approved_at
      t.datetime :rejected_at
      t.text :message

      t.timestamps
    end
  end
end
