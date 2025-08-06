class QuickMatchHistory < ApplicationRecord
  belongs_to :user
  belongs_to :game, optional: true
  belongs_to :match_pool, optional: true

  # Validations
  validates :match_type, inclusion: { in: %w[instant_match pool_match] }

  # Scopes
  scope :successful, -> { where(successful: true) }
  scope :failed, -> { where(successful: false) }
  scope :instant_matches, -> { where(match_type: "instant_match") }
  scope :pool_matches, -> { where(match_type: "pool_match") }
  scope :recent, -> { order(created_at: :desc) }

  def display_status
    if successful?
      game.present? ? "경기 매칭 성공" : "매치 풀 참가"
    else
      "매칭 실패"
    end
  end

  def result_display
    case match_type
    when "instant_match"
      game.present? ? "#{game.court.name} - #{game.scheduled_at.strftime('%m/%d %H:%M')}" : "매칭 실패"
    when "pool_match"
      if match_pool.present?
        "#{match_pool.location_display} - #{match_pool.match_time.strftime('%m/%d %H:%M')}"
      else
        "매칭 실패"
      end
    end
  end

  def search_time_display
    return "-" if search_time_seconds.nil?

    if search_time_seconds < 60
      "#{search_time_seconds}초"
    else
      minutes = search_time_seconds / 60
      seconds = search_time_seconds % 60
      "#{minutes}분 #{seconds}초"
    end
  end
end
