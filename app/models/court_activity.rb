class CourtActivity < ApplicationRecord
  belongs_to :court
  belongs_to :user

  # 활동 타입 상수
  ACTIVITY_TYPES = {
    "check_in" => "체크인",
    "game_report" => "경기 진행 중",
    "check_out" => "체크아웃",
    "court_update" => "코트 상태 업데이트"
  }.freeze

  validates :activity_type, presence: true, inclusion: { in: ACTIVITY_TYPES.keys }
  validates :recorded_at, presence: true
  validates :player_count, numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { order(recorded_at: :desc) }
  scope :today, -> { where(recorded_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :by_type, ->(type) { where(activity_type: type) }

  # 콜백
  after_create :update_court_realtime_data

  private

  def update_court_realtime_data
    court.update_realtime_status!
  end
end
