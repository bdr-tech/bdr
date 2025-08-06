class EvaluationDeadline < ApplicationRecord
  belongs_to :game

  validates :deadline, presence: true

  scope :active, -> { where(is_active: true).where("deadline > ?", Time.current) }
  scope :expired, -> { where("deadline <= ?", Time.current) }

  def expired?
    !is_active || deadline <= Time.current
  end

  def time_remaining
    return 0 if expired?
    (deadline - Time.current).to_i
  end
end
