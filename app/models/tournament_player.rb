class TournamentPlayer < ApplicationRecord
  belongs_to :tournament_team
  belongs_to :user
  
  validates :user_id, uniqueness: { scope: :tournament_team_id, message: "이미 팀에 등록되어 있습니다" }
  validates :jersey_number, uniqueness: { scope: :tournament_team_id }, allow_nil: true
  
  scope :active, -> { where(is_active: true) }
  scope :starters, -> { where(is_starter: true) }
  
  def player_info
    {
      id: user.id,
      name: user.name,
      nickname: user.nickname,
      position: position || user.positions&.first,
      jersey_number: jersey_number,
      is_starter: is_starter,
      is_active: is_active
    }
  end
end