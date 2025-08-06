class MatchPool < ApplicationRecord
  # Associations
  has_many :match_pool_participants, dependent: :destroy
  has_many :users, through: :match_pool_participants
  has_many :quick_match_histories
  belongs_to :created_game, class_name: "Game", optional: true

  # Validations
  validates :city, presence: true
  validates :match_time, presence: true
  validates :current_players, numericality: { greater_than_or_equal_to: 0 }
  validates :min_players, numericality: { greater_than_or_equal_to: 4 }
  validates :max_players, numericality: { greater_than_or_equal_to: 4 }
  validates :status, inclusion: { in: %w[forming ready game_created cancelled] }
  validates :game_type, inclusion: { in: %w[pickup guest team_vs_team] }
  validate :match_time_in_future
  validate :max_players_greater_than_min

  # Scopes
  scope :forming, -> { where(status: "forming") }
  scope :ready, -> { where(status: "ready") }
  scope :upcoming, -> { where("match_time > ?", Time.current) }
  scope :for_city, ->(city) { where(city: city) }
  scope :for_skill_level, ->(level, range = 1) {
    where(skill_level: (level - range)..(level + range))
  }

  # Callbacks
  after_update :check_if_ready, if: :saved_change_to_current_players?

  def full?
    current_players >= max_players
  end

  def has_minimum_players?
    current_players >= min_players
  end

  def spots_remaining
    max_players - current_players
  end

  def progress_percentage
    (current_players.to_f / min_players * 100).round
  end

  def time_until_match
    return nil if match_time <= Time.current
    distance_of_time_in_words(Time.current, match_time)
  end

  def can_join?(user)
    !full? &&
    status == "forming" &&
    match_time > Time.current &&
    !match_pool_participants.exists?(user: user)
  end

  def location_display
    district.present? ? "#{city} #{district}" : city
  end

  def skill_level_display
    case skill_level
    when 1 then "초급"
    when 2 then "초중급"
    when 3 then "중급"
    when 4 then "중상급"
    when 5 then "상급"
    else "모든 레벨"
    end
  end

  private

  def check_if_ready
    if has_minimum_players? && status == "forming"
      update_column(:status, "ready")
      MatchPoolProcessingJob.perform_later(id)
    end
  end

  def match_time_in_future
    if match_time.present? && match_time <= Time.current
      errors.add(:match_time, "는 현재 시간 이후여야 합니다")
    end
  end

  def max_players_greater_than_min
    if max_players.present? && min_players.present? && max_players < min_players
      errors.add(:max_players, "는 최소 인원보다 많아야 합니다")
    end
  end
end
