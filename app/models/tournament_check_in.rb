class TournamentCheckIn < ApplicationRecord
  belongs_to :tournament
  belongs_to :user
  belongs_to :tournament_team, optional: true

  ROLES = %w[player coach spectator staff].freeze

  validates :role, inclusion: { in: ROLES }
  validates :qr_code, uniqueness: true, allow_nil: true

  before_create :generate_qr_code

  scope :checked_in, -> { where.not(checked_in_at: nil) }
  scope :pending, -> { where(checked_in_at: nil) }
  scope :players, -> { where(role: "player") }
  scope :recent, -> { order(checked_in_at: :desc) }

  def checked_in?
    checked_in_at.present?
  end

  def check_in!(device_info = nil)
    update!(
      checked_in_at: Time.current,
      device_info: device_info
    )
  end

  private

  def generate_qr_code
    self.qr_code = SecureRandom.hex(16) if qr_code.blank?
  end
end
