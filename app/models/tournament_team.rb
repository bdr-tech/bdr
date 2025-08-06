class TournamentTeam < ApplicationRecord
  belongs_to :tournament
  belongs_to :captain, class_name: "User"
  belongs_to :team, optional: true
  has_many :tournament_players, dependent: :destroy
  has_many :players, through: :tournament_players, source: :user
  has_many :home_matches, class_name: "TournamentMatch", foreign_key: "home_team_id"
  has_many :away_matches, class_name: "TournamentMatch", foreign_key: "away_team_id"
  has_many :won_matches, class_name: "TournamentMatch", foreign_key: "winner_team_id"

  validates :team_name, presence: true, uniqueness: { scope: :tournament_id }
  validates :status, inclusion: { in: %w[pending approved rejected withdrawn] }
  validates :contact_phone, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :with_payment, -> { where(payment_completed: true) }

  before_create :set_registered_at

  def all_matches
    TournamentMatch.where("home_team_id = ? OR away_team_id = ?", id, id)
  end

  def roster_players
    JSON.parse(roster || "[]")
  rescue
    []
  end

  def add_player(player_info)
    players = roster_players
    players << player_info
    self.roster = players.to_json
  end

  def remove_player(player_index)
    players = roster_players
    players.delete_at(player_index)
    self.roster = players.to_json
  end

  def win_percentage
    total_games = wins + losses
    return 0 if total_games == 0
    (wins.to_f / total_games * 100).round(1)
  end

  def point_differential
    points_for - points_against
  end

  def approve!
    update(status: "approved", approved_at: Time.current)
  end

  def reject!
    update(status: "rejected")
  end

  def withdraw!
    update(status: "withdrawn")
  end
  
  # QR code generation
  def generate_qr_token!
    token = SecureRandom.hex(16)
    while TournamentTeam.exists?(qr_token: token)
      token = SecureRandom.hex(16)
    end
    update!(qr_token: token)
    token
  end
  
  # Get QR code
  def qr_code
    return nil unless qr_token.present?
    
    begin
      require 'rqrcode' unless defined?(RQRCode)
      qrcode = RQRCode::QRCode.new(qr_token)
      qrcode.as_svg(
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 6,
        standalone: true,
        use_path: true
      )
    rescue LoadError, NameError
      # Fallback if RQRCode is not available
      # Return a simple text representation or nil
      Rails.logger.warn "RQRCode gem not available for QR code generation"
      nil
    end
  end
  
  # Check in team
  def check_in!
    update!(checked_in: true, checked_in_at: Time.current)
  end
  
  # Check out team
  def check_out!
    update!(checked_in: false, checked_in_at: nil)
  end

  private

  def set_registered_at
    self.registered_at ||= Time.current
  end
end
