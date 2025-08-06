class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.references :court, null: false, foreign_key: true
      t.integer :organizer_id
      t.datetime :scheduled_at
      t.string :status
      t.integer :max_players

      t.timestamps
    end
  end
end
