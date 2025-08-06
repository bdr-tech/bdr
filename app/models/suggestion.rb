class Suggestion < ApplicationRecord
  belongs_to :user

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :status, presence: true, inclusion: { in: %w[pending reviewing resolved closed] }

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :reviewing, -> { where(status: "reviewing") }
  scope :resolved, -> { where(status: "resolved") }
  scope :closed, -> { where(status: "closed") }
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where.not(status: [ "resolved", "closed" ]) }

  # Status helpers
  def mark_as_reviewing!
    update!(status: "reviewing")
  end

  def mark_as_resolved!(response)
    update!(status: "resolved", admin_response: response)
  end

  def mark_as_closed!(response = nil)
    update!(status: "closed", admin_response: response)
  end
end
