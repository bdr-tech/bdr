class Team < ApplicationRecord
  belongs_to :captain, class_name: 'User'
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :tournament_teams
  
  validates :name, presence: true, uniqueness: { scope: :captain_id }
  validates :captain, presence: true
  validate :captain_must_be_premium
  
  scope :active, -> { where(is_active: true) }
  scope :with_members, -> { includes(:team_members, :users) }
  
  def add_member(user, role = 'player')
    team_members.create(user: user, role: role) unless has_member?(user)
  end
  
  def remove_member(user)
    team_members.find_by(user: user)&.destroy
  end
  
  def has_member?(user)
    users.include?(user)
  end
  
  def member_count
    team_members.count
  end
  
  def roster
    team_members.includes(:user).map do |member|
      {
        id: member.user.id,
        name: member.user.name,
        nickname: member.user.nickname,
        position: member.user.positions&.first,
        role: member.role,
        jersey_number: member.jersey_number,
        is_active: member.is_active
      }
    end
  end
  
  def available_for_tournament?
    is_active && member_count >= 5
  end
  
  private
  
  def captain_must_be_premium
    return unless captain.present?
    
    unless captain.premium?
      errors.add(:captain, '은(는) 프리미엄 회원이어야 팀을 생성할 수 있습니다.')
    end
  end
end