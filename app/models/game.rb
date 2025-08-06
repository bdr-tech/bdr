class Game < ApplicationRecord
  belongs_to :court, optional: true  # court는 이제 선택사항
  belongs_to :organizer, class_name: "User"
  alias_method :host, :organizer
  has_many :game_participations
  has_many :players, through: :game_participations, source: :user
  has_many :game_applications
  has_many :game_results
  has_many :reviews, as: :reviewable
  has_many :activities, as: :trackable
  has_many :ratings, dependent: :destroy
  has_many :player_evaluations, dependent: :destroy
  has_one :evaluation_deadline, dependent: :destroy

  validates :scheduled_at, presence: true
  validates :status, inclusion: { in: %w[scheduled active closed completed cancelled] }
  validates :max_players, presence: true, numericality: { greater_than: 1 }

  # 새로운 필드 검증
  validates :game_type, presence: true, inclusion: { in: %w[픽업게임 게스트모집 TvT연습경기] }
  validates :team_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :city, presence: true
  validates :district, presence: true
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :venue_name, presence: true
  validates :venue_address, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :level, presence: true, numericality: { in: 1..5 }
  validates :fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :game_id, presence: true, uniqueness: true

  validate :end_time_after_start_time
  validate :uniform_colors_limit
  # validate :host_date_restriction # 비활성화

  before_validation :set_default_status, on: :create
  before_validation :generate_game_id, on: :create
  before_validation :set_platform_fee_percentage, on: :create

  # 경기 생성 시 리마인더 예약
  after_create :schedule_game_reminders

  # 경기 상태 변경 시 평가 알림 예약
  after_update :schedule_evaluation_reminder, if: :completed_status_changed?

  # 유니폼 색상 배열 시리얼라이저
  serialize :uniform_colors, coder: JSON

  scope :upcoming, -> { where("scheduled_at > ?", Time.current) }
  scope :today, -> { where(scheduled_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :active, -> { where(status: [ "scheduled", "active" ]) }
  scope :by_game_type, ->(type) { where(game_type: type) if type.present? }
  scope :by_location, ->(city, district = nil) {
    scope = where(city: city)
    scope = scope.where(district: district) if district.present?
    scope
  }
  scope :by_level, ->(level) { where(level: level) if level.present? }

  # 게임 타입 상수
  GAME_TYPES = {
    "픽업게임" => "자유로운 픽업 게임",
    "게스트모집" => "팀원 모집 경기",
    "TvT연습경기" => "팀 대 팀 연습 경기"
  }.freeze

  # 게임 타입 코드 (ID 생성용)
  GAME_TYPE_CODES = {
    "픽업게임" => "PKG",
    "게스트모집" => "GST",
    "TvT연습경기" => "TVT"
  }.freeze

  # 레벨 상수
  LEVELS = {
    1 => "입문자",
    2 => "초급자",
    3 => "중급자",
    4 => "상급자",
    5 => "고급자"
  }.freeze

  # 유니폼 색상 상수
  UNIFORM_COLORS = {
    "white" => "흰색",
    "black" => "검은색",
    "blue" => "파란색",
    "yellow" => "노란색",
    "red" => "빨간색"
  }.freeze

  COLOR_HEX = {
    "white" => "#FFFFFF",
    "black" => "#000000",
    "blue" => "#3B82F6",
    "yellow" => "#FDE047",
    "red" => "#EF4444"
  }.freeze

  # 실제 참가자 수 (최종승인된 참가자만 카운팅)
  def confirmed_players_count
    game_applications.final_approved.count
  end

  def available_spots
    max_players - confirmed_players_count
  end

  def full?
    confirmed_players_count >= max_players
  end

  def can_accept_players?
    !full? && scheduled_at > Time.current
  end

  # 기존 players 관계는 유지하되, 실제 카운팅에는 confirmed_players_count 사용
  def players_count
    confirmed_players_count
  end

  def confirmed_players
    User.joins(:game_applications).where(game_applications: { game: self, status: "final_approved" })
  end

  def game_type_description
    GAME_TYPES[game_type] || game_type
  end

  def level_name
    LEVELS[level] || "레벨 #{level}"
  end

  def location_full_name
    return "" if city.blank? || district.blank?
    "#{city} #{district}"
  end

  def fee_display
    fee == 0 ? "무료" : "#{fee.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end

  def duration_in_hours
    return 0 unless start_time && end_time
    ((end_time - start_time) / 1.hour).round(1)
  end

  def game_type_code
    GAME_TYPE_CODES[game_type] || "UNK"
  end

  def uniform_colors_names
    return [] if uniform_colors.blank?
    uniform_colors.map { |color| UNIFORM_COLORS[color] }.compact
  end

  def color_hex(color)
    COLOR_HEX[color] || "#CCCCCC"
  end

  # 게임 ID로 게임 찾기
  def self.find_by_game_id(game_id)
    find_by(game_id: game_id)
  end

  # URL에서 게임 ID 사용하기 위한 메서드
  def to_param
    game_id
  end

  # 수익 관련 메서드들

  # 예상 총 수익 (모든 참가자가 결제했을 때)
  def expected_total_revenue
    confirmed_players_count * fee
  end

  # 실제 총 수익 (실제로 결제된 금액)
  def actual_total_revenue
    game_applications.joins(:payment)
                    .where(payments: { status: "paid" })
                    .sum("payments.amount")
  end

  # 현재 플랫폼 수수료율 (시스템 설정 우선, 없으면 게임 자체 설정 사용)
  def current_platform_fee_percentage
    system_fee = SystemSetting.get("platform_fee_percentage")
    system_fee ? system_fee.to_f : (platform_fee_percentage || 5.0)
  end

  # 예상 플랫폼 수수료
  def expected_platform_fee
    (expected_total_revenue * current_platform_fee_percentage / 100).round(0)
  end

  # 실제 플랫폼 수수료
  def actual_platform_fee
    game_applications.joins(:payment)
                    .where(payments: { status: "paid" })
                    .sum("payments.fee_amount")
  end

  # 예상 호스트 수익
  def expected_host_revenue
    expected_total_revenue - expected_platform_fee
  end

  # 실제 호스트 수익
  def actual_host_revenue
    actual_total_revenue - actual_platform_fee
  end

  # 결제 대기 중인 금액
  def pending_payment_amount
    game_applications.where(status: "waiting_payment")
                    .count * fee
  end

  # 결제 완료율
  def payment_completion_rate
    return 0 if confirmed_players_count == 0
    return 100 if fee == 0  # 무료 경기는 항상 100%

    paid_count = game_applications.joins(:payment)
                                 .where(game_applications: { status: "final_approved" })
                                 .where(payments: { status: "paid" })
                                 .count
    (paid_count.to_f / confirmed_players_count * 100).round(1)
  end

  # 평가 관련 메서드
  def create_evaluation_deadline!
    return if evaluation_deadline.present?

    # 경기 종료 30분 후부터 24시간 동안 평가 가능
    deadline_time = (end_time || scheduled_at + 2.hours) + 30.minutes + 24.hours
    create_evaluation_deadline(deadline: deadline_time)
  end

  def evaluation_available?
    return false unless evaluation_deadline.present?

    current_time = Time.current
    evaluation_start = (end_time || scheduled_at + 2.hours) + 30.minutes

    current_time >= evaluation_start && !evaluation_deadline.expired?
  end

  # 모든 참가자 목록 (호스트 + 게스트)
  def all_participants
    participant_ids = game_applications.where(status: "final_approved").pluck(:user_id)
    participant_ids << organizer_id
    User.where(id: participant_ids.uniq)
  end

  # 특정 사용자가 평가할 수 있는 다른 참가자들
  def evaluatable_players_for(user)
    return [] unless all_participants.include?(user)
    all_participants.where.not(id: user.id)
  end

  # 경기 복사 기능
  def duplicate_for_host(host_user)
    new_game = self.dup
    new_game.organizer = host_user
    new_game.scheduled_at = nil # 날짜는 새로 설정해야 함
    new_game.start_time = nil
    new_game.end_time = nil
    new_game.status = "scheduled"
    new_game.game_id = nil # 새로 생성됨
    new_game.application_count = 0
    new_game.completion_rate = 0
    new_game.view_count = 0
    new_game.created_at = nil
    new_game.updated_at = nil
    new_game
  end

  # Display helpers
  def level_text
    case level
    when 1 then "입문"
    when 2 then "초급"
    when 3 then "중급"
    when 4 then "상급"
    when 5 then "최상급"
    else "미정"
    end
  end

  def game_type_badge_class
    case game_type
    when "픽업게임"
      "bg-blue-100 text-blue-800"
    when "게스트모집"
      "bg-purple-100 text-purple-800"
    when "TvT연습경기"
      "bg-green-100 text-green-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def display_name
    title.presence || "#{venue_name} #{game_type}"
  end



  private

  # 동일 날짜 제한 검증 (삭제 - 동일 날짜에 여러 경기 허용)
  def host_date_restriction
    # 제한 없음 - 호스트는 동일 날짜에 여러 경기를 주최할 수 있음
  end


  def set_default_status
    self.status ||= "scheduled"
  end

  def end_time_after_start_time
    return unless start_time && end_time

    if end_time <= start_time
      errors.add(:end_time, "종료시간은 시작시간보다 늦어야 합니다")
    end
  end

  def uniform_colors_limit
    return unless uniform_colors.is_a?(Array)

    if uniform_colors.length > 2
      errors.add(:uniform_colors, "유니폼 색상은 최대 2개까지 선택할 수 있습니다")
    end
  end

  def generate_game_id
    return if game_id.present?

    # 날짜 형식: YYYYMMDD
    date_str = (scheduled_at || Date.current).strftime("%Y%m%d")

    # 게임 타입 코드
    type_code = game_type_code

    # 해당 날짜의 같은 게임 타입 중 시퀀스 번호 생성
    sequence = generate_sequence_number(date_str, type_code)

    # 게임 ID 생성: BDR-YYYYMMDD-TYPE-SEQ
    self.game_id = "BDR-#{date_str}-#{type_code}-#{sequence}"
  end

  def generate_sequence_number(date_str, type_code)
    # 해당 날짜의 같은 게임 타입에서 가장 큰 시퀀스 번호 찾기
    prefix = "BDR-#{date_str}-#{type_code}-"

    last_game = Game.where("game_id LIKE ?", "#{prefix}%")
                   .order(:game_id)
                   .last

    if last_game&.game_id
      # 기존 게임 ID에서 시퀀스 번호 추출
      last_sequence = last_game.game_id.split("-").last.to_i
      next_sequence = last_sequence + 1
    else
      next_sequence = 1
    end

    # 3자리 패딩 (001, 002, ...)
    format("%03d", next_sequence)
  end

  def set_platform_fee_percentage
    # 시스템 설정에서 플랫폼 수수료율 가져오기
    system_fee = SystemSetting.get("platform_fee_percentage")
    self.platform_fee_percentage = system_fee.to_f if system_fee.present? && platform_fee_percentage.nil?
  end


  def completed_status_changed?
    saved_change_to_status? && status == "completed"
  end

  def schedule_evaluation_reminder
    # 경기 종료 30분 후에 평가 알림 발송
    evaluation_time = (end_time || scheduled_at + 2.hours) + 30.minutes
    wait_time = evaluation_time - Time.current

    if wait_time > 0
      SendEvaluationReminderJob.set(wait: wait_time).perform_later(id)
    else
      # 이미 30분이 지났다면 즉시 발송
      SendEvaluationReminderJob.perform_later(id)
    end
  end

  def schedule_game_reminders
    return unless scheduled_at.present?

    # 1시간 전 알림
    one_hour_before = scheduled_at - 1.hour
    if one_hour_before > Time.current
      SendGameReminderJob.set(wait_until: one_hour_before).perform_later(id)
    end

    # 하루 전 알림 (오전 10시)
    one_day_before = (scheduled_at - 1.day).change(hour: 10, min: 0)
    if one_day_before > Time.current && scheduled_at > Time.current + 1.day
      SendGameReminderJob.set(wait_until: one_day_before).perform_later(id)
    end

    # 경기 시작 시간에 신청 마감 처리 예약
    if scheduled_at > Time.current
      CloseGameApplicationsJob.set(wait_until: scheduled_at).perform_later(id)
    end

    # 경기 종료 시간에 완료 처리 예약
    game_end_time = end_time || (scheduled_at + 2.hours)
    if game_end_time > Time.current
      MarkGameCompletedJob.set(wait_until: game_end_time).perform_later(id)
    end
  end
end
