class UpdateGamesForNewCreationForm < ActiveRecord::Migration[8.0]
  def change
    # 1단계 필드들
    add_column :games, :game_type, :string # 픽업게임, 게스트모집, TvT연습경기
    add_column :games, :team_name, :string
    add_column :games, :city, :string
    add_column :games, :district, :string

    # 2단계 필드들
    add_column :games, :title, :string
    add_column :games, :venue_name, :string
    add_column :games, :venue_address, :string
    add_column :games, :start_time, :time
    add_column :games, :end_time, :time
    add_column :games, :level, :integer # 1-10단계
    add_column :games, :fee, :integer # 참가비

    # 3단계 필드들 (facility requirements)
    add_column :games, :parking_required, :boolean, default: false
    add_column :games, :shower_required, :boolean, default: false
    add_column :games, :water_fountain_required, :boolean, default: false
    add_column :games, :air_conditioning_required, :boolean, default: false
    add_column :games, :message, :text # 간단한 전달사항

    # 인덱스 추가
    add_index :games, :game_type
    add_index :games, [ :city, :district ]
    add_index :games, :level
  end
end
