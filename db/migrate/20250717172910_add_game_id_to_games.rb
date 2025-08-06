class AddGameIdToGames < ActiveRecord::Migration[8.0]
  def change
    # 먼저 nullable로 컬럼 추가
    add_column :games, :game_id, :string

    # 기존 게임들에 대해 game_id 생성
    reversible do |dir|
      dir.up do
        Game.find_each do |game|
          game.send(:generate_game_id)
          game.save!(validate: false)
        end

        # 이제 NOT NULL 제약 조건 추가
        change_column_null :games, :game_id, false
      end
    end

    add_index :games, :game_id, unique: true
  end
end
