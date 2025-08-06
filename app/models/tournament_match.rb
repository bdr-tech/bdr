class TournamentMatch < ApplicationRecord
  belongs_to :tournament
  belongs_to :home_team, class_name: "TournamentTeam", optional: true
  belongs_to :away_team, class_name: "TournamentTeam", optional: true
  belongs_to :winner_team, class_name: "TournamentTeam", optional: true
  has_many :match_player_stats, dependent: :destroy

  validates :status, inclusion: { in: %w[scheduled ongoing completed cancelled] }
  validates :home_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :away_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :scheduled, -> { where(status: "scheduled") }
  scope :completed, -> { where(status: "completed") }
  scope :upcoming, -> { scheduled.where("scheduled_at > ?", Time.current).order(:scheduled_at) }

  def team_names
    "#{home_team&.team_name || 'TBD'} vs #{away_team&.team_name || 'TBD'}"
  end

  def complete_match!(home_score, away_score)
    transaction do
      self.home_score = home_score
      self.away_score = away_score
      self.status = "completed"

      if home_score > away_score
        self.winner_team = home_team
        home_team.increment!(:wins)
        away_team.increment!(:losses)
      else
        self.winner_team = away_team
        away_team.increment!(:wins)
        home_team.increment!(:losses)
      end

      home_team.increment!(:points_for, home_score)
      home_team.increment!(:points_against, away_score)
      away_team.increment!(:points_for, away_score)
      away_team.increment!(:points_against, home_score)

      save!
    end
  end

  def can_start?
    status == "scheduled" &&
    scheduled_at <= Time.current &&
    home_team.present? &&
    away_team.present?
  end

  def score_display
    return "-" unless completed?
    "#{home_score} - #{away_score}"
  end

  def completed?
    status == "completed"
  end

  def round_name
    case round
    when "final"
      "결승"
    when "semi_final"
      "준결승"
    when "quarter_final"
      "8강"
    when "round_of_16"
      "16강"
    when "round_of_32"
      "32강"
    when "round_of_8"
      "8강"
    when "group_stage"
      "조별리그"
    when "preliminary"
      "예선"
    else
      round&.humanize || "라운드"
    end
  end
end
