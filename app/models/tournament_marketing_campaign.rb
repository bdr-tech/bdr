class TournamentMarketingCampaign < ApplicationRecord
  belongs_to :tournament

  # Validations
  validates :campaign_type, presence: true
  validates :channel, presence: true, inclusion: { in: %w[email push sms all] }
  validates :recipients_count, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :sent, -> { where.not(sent_at: nil) }
  scope :pending, -> { where(sent_at: nil) }
  scope :by_type, ->(type) { where(campaign_type: type) }
  scope :by_channel, ->(channel) { where(channel: channel) }
  scope :recent, -> { order(created_at: :desc) }

  # Campaign types
  CAMPAIGN_TYPES = {
    "announcement" => "대회 공지",
    "registration_open" => "등록 오픈",
    "deadline_reminder" => "마감 임박",
    "final_call" => "최종 안내",
    "tournament_reminder" => "대회 리마인더",
    "game_day" => "대회 당일"
  }.freeze

  # Channels
  CHANNELS = {
    "email" => "이메일",
    "push" => "푸시 알림",
    "sms" => "SMS",
    "all" => "전체 채널"
  }.freeze

  def display_name
    "#{CAMPAIGN_TYPES[campaign_type]} - #{CHANNELS[channel]}"
  end

  def sent?
    sent_at.present?
  end

  def pending?
    sent_at.nil?
  end

  def open_rate
    return 0 unless sent? && recipients_count > 0
    (opened_count.to_f / recipients_count * 100).round(1)
  end

  def click_rate
    return 0 unless sent? && recipients_count > 0
    (clicked_count.to_f / recipients_count * 100).round(1)
  end

  def engagement_rate
    return 0 unless sent? && recipients_count > 0
    ((opened_count + clicked_count).to_f / (recipients_count * 2) * 100).round(1)
  end

  def track_open!(user_id = nil)
    increment!(:opened_count)
    # 추가로 user_id별 추적 로직 구현 가능
  end

  def track_click!(user_id = nil)
    increment!(:clicked_count)
    # 추가로 user_id별 추적 로직 구현 가능
  end

  def effectiveness_score
    # 효과성 점수 계산 (0-100)
    return 0 unless sent?

    base_score = 0
    base_score += open_rate * 0.3  # 오픈율 30% 반영
    base_score += click_rate * 0.7  # 클릭율 70% 반영

    # 채널별 가중치
    channel_weight = case channel
    when "push" then 1.2
    when "email" then 1.0
    when "sms" then 1.1
    else 1.0
    end

    (base_score * channel_weight).round(1).clamp(0, 100)
  end
end
