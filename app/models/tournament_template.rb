class TournamentTemplate < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :template_type, presence: true
  validates :configuration, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_type, ->(type) { where(template_type: type) }

  # Template types
  TEMPLATE_TYPES = {
    "weekend_tournament" => "주말 토너먼트",
    "league" => "리그전",
    "knockout" => "토너먼트",
    "round_robin" => "풀리그",
    "3on3" => "3대3 대회",
    "corporate" => "기업 대회"
  }.freeze

  def display_name
    "#{name} (#{TEMPLATE_TYPES[template_type]})"
  end

  def apply_to_tournament(tournament)
    config = configuration.with_indifferent_access

    tournament.tournament_type = config[:tournament_type] if config[:tournament_type].present?
    tournament.max_teams = config[:max_teams] if config[:max_teams].present?
    tournament.rules = config[:rules] if config[:rules].present?
    tournament.auto_bracket_generated = config[:auto_bracket_generated] if config.key?(:auto_bracket_generated)
    tournament.auto_notification_enabled = config[:auto_notification_enabled] if config.key?(:auto_notification_enabled)

    # 일정 템플릿 적용
    if config[:schedule_template].present?
      apply_schedule_template(tournament, config[:schedule_template])
    end

    tournament
  end

  private

  def apply_schedule_template(tournament, schedule_template)
    case schedule_template["type"]
    when "single_day"
      # 하루 대회
      tournament.tournament_start_at = next_occurrence_of_day(schedule_template["day_of_week"])
      tournament.tournament_end_at = tournament.tournament_start_at.end_of_day
      tournament.registration_end_at = tournament.tournament_start_at - 1.day
      tournament.registration_start_at = tournament.registration_end_at - 1.week

    when "weekend"
      # 주말 대회
      next_saturday = next_occurrence_of_day("saturday")
      tournament.tournament_start_at = next_saturday
      tournament.tournament_end_at = next_saturday + 1.day
      tournament.registration_end_at = next_saturday - 2.days
      tournament.registration_start_at = tournament.registration_end_at - 2.weeks

    when "weekly_league"
      # 주간 리그
      tournament.tournament_start_at = 1.week.from_now.beginning_of_week
      tournament.tournament_end_at = 4.weeks.from_now.end_of_week
      tournament.registration_end_at = tournament.tournament_start_at - 3.days
      tournament.registration_start_at = 2.weeks.from_now
    end
  end

  def next_occurrence_of_day(day_name)
    date = Date.current
    date += 1.day until date.strftime("%A").downcase == day_name.downcase
    date.beginning_of_day + 9.hours # 오전 9시 시작
  end
end
