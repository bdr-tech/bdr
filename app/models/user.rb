class User < ApplicationRecord
  # Game associations
  has_many :organized_games, class_name: "Game", foreign_key: "organizer_id"
  has_many :game_participations
  has_many :games, through: :game_participations
  has_many :game_applications
  has_many :game_results

  # Community associations
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reviews

  # User data associations
  has_one :user_stat, dependent: :destroy
  has_one :play_style, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  has_many :court_visits, dependent: :destroy
  has_many :visited_courts, through: :court_visits, source: :court
  has_many :premium_subscriptions, dependent: :destroy
  has_many :billing_keys, dependent: :destroy

  # Evaluation associations
  has_many :given_evaluations, class_name: "PlayerEvaluation", as: :evaluator, dependent: :destroy
  has_many :received_evaluations, class_name: "PlayerEvaluation", foreign_key: :evaluated_user_id, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :outdoor_courts, dependent: :destroy
  has_one :user_cancellation, dependent: :destroy
  has_many :user_rating_histories, dependent: :destroy
  has_many :court_activities, dependent: :destroy

  # Rating associations
  has_many :given_ratings, class_name: "Rating", foreign_key: "user_id", dependent: :destroy
  has_many :received_ratings, class_name: "Rating", foreign_key: "rated_user_id", dependent: :destroy

  # Point and suggestion associations
  has_many :user_points, dependent: :destroy
  has_many :suggestions, dependent: :destroy

  # Notification associations
  has_many :notifications, dependent: :destroy
  has_many :unread_notifications, -> { unread_only }, class_name: "Notification"

  # Tournament associations
  has_many :organized_tournaments, class_name: "Tournament", foreign_key: "organizer_id", dependent: :destroy
  has_many :active_tournaments, -> { where(status: [ "draft", "registration_open", "ongoing" ]) }, class_name: "Tournament", foreign_key: "organizer_id"
  has_many :tournament_templates, foreign_key: "creator_id", dependent: :destroy
  
  # Team associations
  has_many :captained_teams, class_name: "Team", foreign_key: "captain_id", dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members

  # Quick match associations
  has_one :quick_match_preference, dependent: :destroy
  has_many :match_pool_participants, dependent: :destroy
  has_many :quick_match_histories, dependent: :destroy

  # Stats associations
  has_many :player_stats, dependent: :destroy
  has_many :season_averages, dependent: :destroy

  serialize :positions, coder: JSON

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :nickname, presence: true, uniqueness: true, if: :profile_required?
  validates :real_name, presence: true, if: :profile_required?
  validates :phone, presence: true, uniqueness: true, if: :profile_required?
  validates :height, presence: true, numericality: { greater_than: 0 }, if: :profile_required?
  validates :weight, presence: true, numericality: { greater_than: 0 }, if: :profile_required?
  validates :positions, presence: true, if: :profile_required?
  validates :city, presence: true, if: :profile_required?
  validates :district, presence: true, if: :profile_required?


  SKILL_LEVELS = {
    1 => "초보자",
    2 => "입문자",
    3 => "아마추어",
    4 => "중급자",
    5 => "상급자",
    6 => "세미프로",
    7 => "프로급"
  }.freeze

  POSITIONS = %w[포인트가드 슈팅가드 스몰포워드 파워포워드 센터].freeze

  scope :profile_completed, -> { where(profile_completed: true) }
  scope :profile_incomplete, -> { where(profile_completed: false) }

  before_save :check_profile_completion

  def full_profile_fields
    %w[nickname real_name phone height weight positions city district birth_date basketball_experience]
  end

  def profile_completion_percentage
    completed_fields = full_profile_fields.count { |field| send(field).present? }
    (completed_fields.to_f / full_profile_fields.count * 100).round
  end

  def can_participate_in_games?
    profile_completion_percentage >= 70
  end

  def skill_level_name
    SKILL_LEVELS[skill_level] || "미정"
  end

  def skill_level
    # old_skill_level이 있으면 사용, 없으면 평균 평점 기반으로 계산
    if old_skill_level.present?
      old_skill_level
    else
      # 평균 평점(0-5) 기반으로 스킬 레벨(1-7) 계산
      avg = average_rating
      case avg
      when 0..1 then 1
      when 1..2 then 2
      when 2..3 then 3
      when 3..3.5 then 4
      when 3.5..4 then 5
      when 4..4.5 then 6
      else 7
      end
    end
  end

  def position_names
    return [] if positions.blank?

    # Ensure positions is always treated as an array
    pos_array = Array(positions)
    pos_array.select { |p| POSITIONS.include?(p) }
  end

  def location_full_name
    return "" if city.blank? || district.blank?
    "#{city} #{district}"
  end

  # 표시용 이름 (닉네임 > 이름 순서로 반환)
  def display_name
    nickname.presence || name
  end

  def age
    return nil unless birth_date.present?
    ((Date.current - birth_date) / 365.25).floor
  end

  def basketball_experience_text
    return "경력 미설정" if basketball_experience.blank?

    years = basketball_experience.to_i
    case years
    when 0
      "초보자"
    when 1..2
      "#{years}년"
    when 3..5
      "#{years}년 (중급자)"
    when 6..9
      "#{years}년 (상급자)"
    else
      "#{years}년 (베테랑)"
    end
  end

  def can_apply_for_games?
    user_cancellation&.can_apply_for_games? != false
  end

  def cancellation_hours_until_reset
    user_cancellation&.hours_until_reset || 0
  end

  # 관리자 권한 관련 메서드
  def admin?
    admin == true
  end

  def make_admin!
    update!(admin: true)
  end

  def remove_admin!
    update!(admin: false)
  end

  # Rating methods (old system)
  def old_average_rating
    # 평점이 없으면 기본값 2.5 (50%)
    received_ratings.any? ? received_ratings.average(:rating) : 2.5
  end

  def rating_percentage
    (old_average_rating / 5.0 * 100).round
  end

  def rating_count
    received_evaluations.completed.count
  end


  def player_rating_average
    # 플레이어 평점이 없으면 기본값 2.5 (50%)
    player_ratings = received_ratings.for_player
    player_ratings.any? ? player_ratings.average(:rating) : 2.5
  end

  def basketball_rating_display
    avg = old_average_rating
    full_balls = avg.floor
    has_half = (avg % 1) >= 0.5

    { full_balls: full_balls, has_half: has_half, percentage: rating_percentage }
  end

  # Notification settings
  def email_notifications?
    email_notifications
  end

  def sms_notifications?
    sms_notifications
  end

  def push_notifications?
    push_notifications
  end

  # Parse notification_preferences JSON and provide defaults
  def notification_preferences_hash
    return default_notification_preferences if notification_preferences.blank?

    begin
      prefs = JSON.parse(notification_preferences)
      default_notification_preferences.merge(prefs)
    rescue JSON::ParserError
      default_notification_preferences
    end
  end

  # Update a specific notification preference
  def update_notification_preference(preference_key, enabled)
    prefs = notification_preferences_hash
    prefs[preference_key] = enabled
    update(notification_preferences: prefs.to_json)
  end

  # Check if a specific notification type is enabled
  def notification_enabled?(notification_type)
    prefs = notification_preferences_hash
    prefs[notification_type] != false
  end

  # Default notification preferences
  def default_notification_preferences
    {
      "game_invitation" => true,
      "game_reminder" => true,
      "game_cancellation" => true,
      "game_application_status" => true,
      "payment_confirmation" => true,
      "community_mention" => true,
      "community_reply" => true,
      "rating_received" => true,
      "achievement_unlocked" => true,
      "marketing" => marketing_consent
    }
  end

  # Cached methods
  def cached_unread_notifications_count
    Rails.cache.fetch([ "user", id, "unread_notifications_count" ], expires_in: 5.minutes) do
      unread_notifications.count
    end
  end

  def cached_profile_data
    Rails.cache.fetch([ "user", id, "profile_data", updated_at ], expires_in: 1.hour) do
      {
        games_count: games.count,
        organized_games_count: organized_games.count,
        applications_count: game_applications.count,
        average_rating: average_rating,
        rating_count: rating_count,
        player_rating_average: player_rating_average,
        profile_completion: profile_completion_percentage
      }
    end
  end

  def clear_cache!
    Rails.cache.delete([ "user", id, "unread_notifications_count" ])
    Rails.cache.delete([ "user", id, "profile_data", updated_at ])
  end

  # Clear cache when notifications are updated
  after_commit :clear_notification_cache, if: -> { saved_change_to_attribute?(:updated_at) }

  def clear_notification_cache
    Rails.cache.delete([ "user", id, "unread_notifications_count" ])
  end

  # Premium membership checks
  def premium?
    is_premium && (premium_expires_at.nil? || premium_expires_at > Time.current)
  end

  def premium_active?
    premium?
  end

  def premium_expired?
    is_premium && premium_expires_at.present? && premium_expires_at <= Time.current
  end

  def premium_days_remaining
    return nil unless premium? && premium_expires_at.present?
    ((premium_expires_at - Time.current) / 1.day).ceil
  end

  # 회원 등급 체크
  def membership_level
    return "admin" if admin?
    return "premium" if premium?
    "basic"
  end

  def membership_badge_text
    case membership_level
    when "admin"
      "관리자"
    when "premium"
      case premium_type
      when "monthly"
        "프리미엄 (월간)"
      when "yearly"
        "프리미엄 (연간)"
      when "lifetime"
        "프리미엄 (평생)"
      else
        "프리미엄"
      end
    else
      "일반"
    end
  end

  def can_create_tournament?
    admin? || is_premium?
  end

  # 대회 개최 제한
  def max_concurrent_tournaments
    if admin?
      999  # 관리자는 무제한
    elsif is_premium?
      5    # 프리미엄 사용자는 5개까지
    else
      0    # 일반 사용자는 개최 불가
    end
  end

  def active_tournaments_count
    active_tournaments.count
  end

  def can_create_more_tournaments?
    active_tournaments_count < max_concurrent_tournaments
  end

  def can_view_tournament_details?
    admin? || premium?
  end

  def is_premium_member?
    premium?
  end

  def is_pro_member?
    false  # 프로 플랜은 현재 사용하지 않음
  end

  # Stats helpers
  def current_season_stats
    SeasonAverage.find_or_create_current_season(self)
  end

  def career_stats
    {
      games_played: player_stats.count,
      points_per_game: player_stats.average(:points) || 0,
      rebounds_per_game: player_stats.average(:total_rebounds) || 0,
      assists_per_game: player_stats.average(:assists) || 0,
      field_goal_percentage: calculate_career_shooting_percentage(:field_goals),
      three_point_percentage: calculate_career_shooting_percentage(:three_pointers),
      free_throw_percentage: calculate_career_shooting_percentage(:free_throws)
    }
  end

  # 평가 관련 메서드
  def average_rating
    # 새로운 평점 시스템 사용 (0~100% -> 0~5 스케일로 변환)
    # evaluation_rating이 없으면 old_average_rating 사용
    if evaluation_rating.present?
      evaluation_rating / 20.0
    else
      old_average_rating
    end
  end

  def evaluation_rating_percentage
    evaluation_rating || 50.0
  end

  def skill_level_average
    avg = received_evaluations.average(:skill_level)
    avg ? avg.round(1) : 0.0
  end

  def teamwork_average
    avg = received_evaluations.average(:teamwork)
    avg ? avg.round(1) : 0.0
  end

  def manner_average
    avg = received_evaluations.average(:manner)
    avg ? avg.round(1) : 0.0
  end

  def memorable_count
    received_evaluations.memorable.count
  end

  # 특정 경기에 대한 평가 여부 확인
  def evaluated_for_game?(game)
    given_evaluations.for_game(game).exists?
  end

  # 특정 사용자에 대한 평가 여부 확인
  def evaluated_user_in_game?(user, game)
    given_evaluations.for_game(game).where(evaluated_user: user).exists?
  end

  # 호스트 관련 메서드
  def can_host_games?
    # 호스트 인증 없이도 모든 사용자가 경기를 주최할 수 있음
    true
  end

  def can_create_premium_games?
    premium?
  end

  def max_concurrent_games
    if admin?
      999  # 관리자는 무제한
    elsif premium?
      10   # 프리미엄 사용자는 10개까지
    else
      3    # 일반 사용자는 3개까지 (1개에서 3개로 상향)
    end
  end

  def active_hosted_games_count
    organized_games.where(status: [ "upcoming", "recruiting" ]).count
  end

  def can_create_more_games?
    active_hosted_games_count < max_concurrent_games
  end

  # 포인트 추가 메서드
  def add_points(amount, reason = nil)
    ActiveRecord::Base.transaction do
      # 포인트 기록 생성
      user_points.create!(
        points: amount,
        reason: reason || "포인트 획득",
        earned_at: Time.current
      )

      # 총 포인트 업데이트
      self.total_points ||= 0
      self.total_points += amount
      save!
    end
  end

  # 퀵매치 관련 메서드
  def quick_match_enabled?
    quick_match_preference&.auto_match_enabled? || false
  end

  def preferred_locations
    quick_match_preference&.preferred_locations || []
  end

  def preferred_times
    quick_match_preference&.preferred_times || {}
  end

  # 프리미엄 회원 업데이트 시 대회 개최 권한 부여
  after_save :update_tournament_permissions

  def update_tournament_permissions
    if saved_change_to_is_premium?
      if is_premium?
        update_columns(
          can_create_tournaments: true,
          max_concurrent_tournaments: 5,
          quick_match_priority: 1
        )
      else
        update_columns(
          can_create_tournaments: false,
          max_concurrent_tournaments: 0,
          quick_match_priority: 0
        )
      end
    end
  end

  private

  def calculate_career_shooting_percentage(type)
    made = player_stats.sum("#{type}_made")
    attempted = player_stats.sum("#{type}_attempted")
    return 0.0 if attempted == 0
    (made.to_f / attempted * 100).round(1)
  end

  def profile_required?
    profile_completed? || profile_completion_percentage >= 80
  end

  def check_profile_completion
    self.profile_completed = full_profile_fields.all? { |field| send(field).present? }
  end

  def increment_tournaments_hosted!
    increment!(:tournaments_hosted_count)
  end
end
