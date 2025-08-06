class AddTournamentCodeToTournaments < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :tournament_code, :string
    add_index :tournaments, :tournament_code, unique: true

    # 기존 대회들에 대한 코드 생성
    reversible do |dir|
      dir.up do
        Tournament.reset_column_information
        Tournament.find_each do |tournament|
          year = tournament.tournament_start_at&.year || Time.current.year
          month = tournament.tournament_start_at&.month || Time.current.month
          type_code = case tournament.tournament_type
          when 'single_elimination' then 'SE'
          when 'double_elimination' then 'DE'
          when 'round_robin' then 'RR'
          when 'group_stage' then 'GS'
          else 'OT'
          end

          # 같은 년월의 대회 수 계산
          count = Tournament.where("tournament_start_at >= ? AND tournament_start_at < ?",
                                 Date.new(year, month, 1),
                                 Date.new(year, month, 1).next_month).count

          tournament.update_column(:tournament_code, "KBT#{year}#{month.to_s.rjust(2, '0')}#{type_code}#{(count + 1).to_s.rjust(3, '0')}")
        end
      end
    end
  end
end
