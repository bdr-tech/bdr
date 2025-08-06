class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :trackable, polymorphic: true

  validates :activity_type, presence: true

  serialize :metadata, coder: JSON

  ACTIVITY_TYPES = %w[
    game_played
    game_won
    game_lost
    review_posted
    achievement_earned
    mvp_earned
    court_visited
    profile_updated
  ].freeze

  validates :activity_type, inclusion: { in: ACTIVITY_TYPES }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(activity_type: type) }

  def self.create_activity(user, type, trackable, metadata = {})
    create!(
      user: user,
      activity_type: type,
      trackable: trackable,
      metadata: metadata
    )
  end

  def activity_description
    case activity_type
    when "game_played"
      "#{trackable.title || '경기'}에 참가했습니다"
    when "game_won"
      "#{trackable.title || '경기'}에서 승리했습니다"
    when "game_lost"
      "#{trackable.title || '경기'}에서 패배했습니다"
    when "review_posted"
      "리뷰를 작성했습니다"
    when "achievement_earned"
      "#{trackable.name} 뱃지를 획득했습니다"
    when "mvp_earned"
      "MVP를 달성했습니다"
    when "court_visited"
      "#{trackable.name}를 방문했습니다"
    when "profile_updated"
      "프로필을 업데이트했습니다"
    else
      "활동을 완료했습니다"
    end
  end

  def activity_icon
    case activity_type
    when "game_played", "game_won", "game_lost"
      "🏀"
    when "review_posted"
      "⭐"
    when "achievement_earned"
      "🏆"
    when "mvp_earned"
      "👑"
    when "court_visited"
      "🏟️"
    when "profile_updated"
      "👤"
    else
      "📋"
    end
  end
end
