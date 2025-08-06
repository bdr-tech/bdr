class Court < ApplicationRecord
  has_many :games
  has_many :court_visits
  has_many :visitors, through: :court_visits, source: :user
  has_many :reviews, as: :reviewable
  has_many :activities, as: :trackable
  has_many :court_activities, dependent: :destroy

  validates :name, presence: true
  validates :address, presence: true
  validates :court_type, inclusion: { in: %w[indoor outdoor] }
  validates :capacity, presence: true, numericality: { greater_than: 0 }

  scope :nearby, ->(lat, lng, radius = 10) {
    where(
      "(6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) < ?",
      lat, lng, lat, radius
    )
  }

  scope :with_realtime, -> { where(realtime_enabled: true) }
  scope :active_now, -> { where("current_occupancy > 0") }

  # 실시간 상태 업데이트
  def update_realtime_status!
    recent_activities = court_activities.where("recorded_at > ?", 30.minutes.ago)

    # 현재 인원 계산
    check_ins = recent_activities.by_type("check_in").sum(:player_count)
    check_outs = recent_activities.by_type("check_out").sum(:player_count)
    game_reports = recent_activities.by_type("game_report").maximum(:player_count) || 0

    new_occupancy = [ check_ins - check_outs, game_reports ].max

    update!(
      current_occupancy: [ new_occupancy, 0 ].max,
      last_activity_at: recent_activities.maximum(:recorded_at) || Time.current
    )

    # 피크 시간 업데이트
    update_peak_hours! if should_update_peak_hours?
  end

  # 피크 시간 분석
  def update_peak_hours!
    activities_by_hour = court_activities
      .where("recorded_at > ?", 30.days.ago)
      .group_by { |a| a.recorded_at.hour }

    peak_data = {}
    (0..23).each do |hour|
      hour_activities = activities_by_hour[hour] || []
      avg_players = hour_activities.any? ?
        (hour_activities.sum(&:player_count) / hour_activities.count.to_f).round(1) :
        0
      peak_data[hour.to_s] = avg_players
    end

    update!(peak_hours: peak_data)
  end

  # 혼잡도 레벨
  def occupancy_level
    return "empty" if current_occupancy == 0
    percentage = (current_occupancy.to_f / capacity * 100).round

    case percentage
    when 0..25 then "low"
    when 26..50 then "moderate"
    when 51..75 then "busy"
    else "full"
    end
  end

  # 혼잡도 색상
  def occupancy_color
    case occupancy_level
    when "empty" then "gray"
    when "low" then "green"
    when "moderate" then "yellow"
    when "busy" then "orange"
    when "full" then "red"
    end
  end

  # 예상 대기 시간
  def estimated_wait_time
    return 0 if current_occupancy < capacity

    # 평균 경기 시간을 1시간으로 가정
    games_in_progress = (current_occupancy.to_f / 10).ceil
    games_in_progress * 30 # 30분 단위
  end

  # 피크 시간대인지 확인
  def peak_time?
    return false unless peak_hours.present?

    current_hour_avg = peak_hours[Time.current.hour.to_s] || 0
    daily_avg = peak_hours.values.sum / 24.0

    current_hour_avg > daily_avg * 1.5
  end

  private

  def should_update_peak_hours?
    peak_hours.blank? || updated_at < 1.hour.ago
  end
end
