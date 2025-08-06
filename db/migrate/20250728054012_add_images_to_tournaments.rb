class AddImagesToTournaments < ActiveRecord::Migration[8.0]
  def change
    # Active Storage를 사용하므로 별도의 컬럼은 필요 없음
    # 대신 이미지 관련 메타데이터를 저장할 컬럼 추가
    add_column :tournaments, :images_count, :integer, default: 0
    add_column :tournaments, :main_image_position, :integer, default: 0
  end
end
