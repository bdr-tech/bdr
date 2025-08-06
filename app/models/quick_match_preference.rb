class QuickMatchPreference < ApplicationRecord
  belongs_to :user

  # Validations
  validates :preferred_level_range, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :max_distance_km, numericality: { greater_than: 0, less_than_or_equal_to: 50 }
  validates :min_players, numericality: { greater_than_or_equal_to: 4, less_than_or_equal_to: 20 }
  validates :max_players, numericality: { greater_than_or_equal_to: 4, less_than_or_equal_to: 20 }
  validate :max_players_greater_than_min

  # Default values
  after_initialize :set_defaults, if: :new_record?

  # Scopes
  scope :auto_match_enabled, -> { where(auto_match_enabled: true) }

  def time_slot_for_day(day_name)
    preferred_times&.dig(day_name.to_s.downcase) || []
  end

  def prefers_location?(location)
    return true if preferred_locations.blank?
    preferred_locations.include?(location)
  end

  def accepts_game_type?(game_type)
    return true if preferred_game_types.blank?
    preferred_game_types.include?(game_type)
  end

  def skill_level_range
    user_level = user.skill_level || 3
    (user_level - preferred_level_range)..(user_level + preferred_level_range)
  end

  private

  def set_defaults
    self.preferred_level_range ||= 1
    self.max_distance_km ||= 10
    self.min_players ||= 6
    self.max_players ||= 10
    self.auto_match_enabled ||= false
    self.preferred_game_types ||= [ "pickup" ]
    self.preferred_times ||= {}
    self.preferred_locations ||= []
  end

  def max_players_greater_than_min
    if max_players.present? && min_players.present? && max_players < min_players
      errors.add(:max_players, "는 최소 인원보다 많아야 합니다")
    end
  end
end
