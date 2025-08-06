class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :user
  
  validates :user_id, uniqueness: { scope: :team_id, message: "이미 팀에 소속되어 있습니다" }
  validates :role, inclusion: { in: %w[captain player substitute coach manager] }
  validates :jersey_number, uniqueness: { scope: :team_id }, allow_nil: true
  
  scope :active, -> { where(is_active: true) }
  scope :players, -> { where(role: ['player', 'substitute']) }
  scope :staff, -> { where(role: ['coach', 'manager']) }
  
  before_validation :set_defaults
  
  def captain?
    role == 'captain'
  end
  
  def player?
    role == 'player' || role == 'substitute'
  end
  
  def can_play?
    is_active && player?
  end
  
  private
  
  def set_defaults
    self.role ||= 'player'
    self.is_active = true if is_active.nil?
  end
end