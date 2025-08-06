class MakeCourtIdOptionalInGames < ActiveRecord::Migration[8.0]
  def change
    change_column_null :games, :court_id, true
  end
end
