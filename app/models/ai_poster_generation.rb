class AIPosterGeneration < ApplicationRecord
  belongs_to :tournament

  # Validations
  validates :prompt, presence: true
  validates :status, inclusion: { in: %w[pending processing completed failed] }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :recent, -> { order(created_at: :desc) }

  def processing_time
    return nil unless completed_at.present?
    (completed_at - created_at).round
  end

  def processing_time_display
    time = processing_time
    return "-" unless time

    if time < 60
      "#{time}초"
    else
      minutes = time / 60
      seconds = time % 60
      "#{minutes}분 #{seconds}초"
    end
  end

  def success?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def can_retry?
    failed? && retry_count < 3
  end

  def retry!
    return false unless can_retry?

    increment!(:retry_count)
    update!(status: "pending", error_message: nil)
    AIPosterGenerationJob.perform_later(tournament_id)
    true
  end
end
