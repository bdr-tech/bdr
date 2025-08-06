class TournamentAutomation < ApplicationRecord
  belongs_to :tournament

  # Validations
  validates :automation_type, presence: true, inclusion: {
    in: %w[marketing_campaign bracket_generation result_processing settlement_processing]
  }
  validates :status, inclusion: { in: %w[scheduled processing completed failed cancelled] }
  validates :scheduled_at, presence: true

  # Scopes
  scope :scheduled, -> { where(status: "scheduled") }
  scope :pending, -> { where(status: "scheduled").where("scheduled_at <= ?", Time.current) }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :by_type, ->(type) { where(automation_type: type) }

  # Automation type display names
  AUTOMATION_TYPES = {
    "marketing_campaign" => "마케팅 캠페인",
    "bracket_generation" => "대진표 자동 생성",
    "result_processing" => "결과 처리",
    "settlement_processing" => "정산 처리"
  }.freeze

  def display_name
    AUTOMATION_TYPES[automation_type] || automation_type
  end

  def due?
    status == "scheduled" && scheduled_at <= Time.current
  end

  def can_execute?
    status == "scheduled" && tournament.present?
  end

  def execute!
    return false unless can_execute?

    update!(status: "processing")
    TournamentAutomationService.execute_automation(self)
    true
  rescue => e
    update!(
      status: "failed",
      executed_at: Time.current,
      execution_log: e.message
    )
    false
  end

  def cancel!
    return false unless status == "scheduled"
    update!(status: "cancelled")
  end

  def execution_time
    return nil unless executed_at.present? && status == "completed"
    executed_at - scheduled_at
  end

  def execution_time_display
    time = execution_time
    return "-" unless time

    if time < 3600
      minutes = (time / 60).round
      "#{minutes}분"
    else
      hours = (time / 3600).round
      "#{hours}시간"
    end
  end
end
