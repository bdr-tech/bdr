class TournamentShareLink < ApplicationRecord
  belongs_to :tournament

  SHARE_TYPES = %w[kakao instagram general qr].freeze

  validates :share_type, inclusion: { in: SHARE_TYPES }
  validates :short_code, presence: true, uniqueness: true
  validates :full_url, presence: true

  before_validation :generate_short_code, on: :create
  before_validation :set_expiry, on: :create

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :popular, -> { order(click_count: :desc) }

  def track_click!
    increment!(:click_count)
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def active?
    !expired?
  end

  def kakao_share_url
    return unless share_type == "kakao"

    params = {
      url: full_url,
      title: "🏀 #{tournament.name}",
      description: tournament.description,
      imageUrl: tournament.poster_url
    }.to_query

    "https://sharer.kakao.com/talk/friends/picker/link?#{params}"
  end

  private

  def generate_short_code
    self.short_code = loop do
      code = SecureRandom.alphanumeric(8)
      break code unless TournamentShareLink.exists?(short_code: code)
    end
  end

  def set_expiry
    self.expires_at = 30.days.from_now if expires_at.blank?
  end
end
