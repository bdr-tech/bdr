class Tournament < ApplicationRecord
  belongs_to :organizer, class_name: "User"
  has_many :tournament_teams, dependent: :destroy
  has_many :tournament_matches, dependent: :destroy
  has_many :approved_teams, -> { where(status: "approved") }, class_name: "TournamentTeam"
  has_many :ai_poster_generations, dependent: :destroy
  has_many :tournament_automations, dependent: :destroy
  has_many :tournament_marketing_campaigns, dependent: :destroy
  has_many :tournament_wizards, dependent: :destroy
  has_many :tournament_check_ins, dependent: :destroy
  has_many :tournament_live_updates, dependent: :destroy
  has_many :tournament_media, dependent: :destroy
  has_many :tournament_budgets, dependent: :destroy
  has_many :tournament_share_links, dependent: :destroy
  has_many :tournament_feedback, dependent: :destroy
  has_many :tournament_checklists, dependent: :destroy
  belongs_to :tournament_template, optional: true

  # Active Storage associations
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 300, 300 ]
    attachable.variant :medium, resize_to_limit: [ 800, 800 ]
  end

  validates :name, presence: true, length: { minimum: 5, maximum: 100 }
  validates :tournament_type, inclusion: { in: %w[single_elimination double_elimination round_robin group_stage] }
  validates :status, inclusion: { in: %w[draft pending_approval published registration_open registration_closed ongoing completed cancelled rejected] }
  validates :min_teams, presence: true, numericality: { greater_than: 1 }
  validates :max_teams, presence: true, numericality: { greater_than_or_equal_to: :min_teams }
  validates :players_per_team, presence: true, numericality: { greater_than: 0 }
  validates :entry_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :organizer_can_create_tournament, on: :create
  validate :validate_images_count

  before_create :generate_tournament_code
  before_create :set_tournament_attributes
  after_create :setup_automations
  after_create :create_default_checklists

  scope :upcoming, -> { where(status: [ "published", "registration_open" ]).where("tournament_start_at > ?", Time.current) }
  scope :pending_approval, -> { where(status: "pending_approval") }
  scope :approved, -> { where(status: [ "published", "registration_open", "registration_closed", "ongoing", "completed" ]) }
  scope :ongoing, -> { where(status: "ongoing") }
  scope :completed, -> { where(status: "completed") }
  scope :featured, -> { where(featured: true) }
  scope :official, -> { where(is_official: true) }
  scope :user_hosted, -> { where(is_official: false) }
  scope :by_premium_users, -> { where(created_by_premium_user: true) }
  scope :registration_open, -> {
    where(status: "registration_open")
    .where("registration_start_at <= ?", Time.current)
    .where("registration_end_at > ?", Time.current)
  }

  def registration_open?
    status == "registration_open" &&
    registration_start_at <= Time.current &&
    registration_end_at > Time.current
  end

  def registration_closed?
    status == "registration_closed" ||
    (registration_end_at && registration_end_at <= Time.current)
  end

  def can_register?
    registration_open? && approved_teams.count < max_teams
  end

  def spots_remaining
    max_teams - approved_teams.count
  end

  def registration_progress_percentage
    return 0 if max_teams == 0
    (approved_teams.count.to_f / max_teams * 100).round
  end

  def days_until_start
    return nil unless tournament_start_at
    ((tournament_start_at - Time.current) / 1.day).ceil
  end

  def total_prize_money
    prizes_array.sum { |prize| prize["amount"].to_i }
  rescue
    0
  end

  def prizes_array
    JSON.parse(prizes || "[]")
  rescue
    []
  end

  def sponsor_list
    sponsor_names&.split(",")&.map(&:strip) || []
  end

  def status_text
    case status
    when "draft"
      "준비중"
    when "pending_approval"
      "승인 대기중"
    when "published"
      "공개됨"
    when "registration_open"
      "등록 접수중"
    when "registration_closed"
      "등록 마감"
    when "ongoing"
      "진행중"
    when "completed"
      "종료"
    when "cancelled"
      "취소됨"
    when "rejected"
      "거절됨"
    else
      status
    end
  end

  # 대회 식별자 (코드가 있으면 코드, 없으면 ID)
  def display_code
    tournament_code || "T#{id.to_s.rjust(6, '0')}"
  end

  # 승인 가능 여부
  def can_approve?
    status == "pending_approval"
  end

  # 대회 승인
  def approve!(notes = nil)
    return false unless can_approve?

    self.status = "published"
    self.approved_at = Time.current
    self.approval_notes = notes if notes.present?
    save
  end

  # 대회 거절
  def reject!(reason)
    return false unless can_approve?

    self.status = "rejected"
    self.rejected_at = Time.current
    self.rejection_reason = reason
    save
  end

  # 플랫폼 수수료 계산
  def calculate_platform_fee
    return 0 if is_official? || entry_fee == 0
    total_revenue * (platform_fee_percentage || 5.0) / 100.0
  end

  # 정산 가능 여부
  def can_settle?
    status == "completed" && settlement_status != "completed"
  end

  # 호스트가 대회를 만들 수 있는지 확인
  def organizer_can_create_tournament?
    return true if organizer.admin?
    return true if is_official?
    organizer.is_premium?
  end
  
  # Calculate progress percentage
  def calculate_progress
    return 0 unless tournament_matches.any?
    
    total_matches = tournament_matches.count
    completed_matches = tournament_matches.where.not(winner_id: nil).count
    
    (completed_matches.to_f / total_matches * 100).round
  end
  
  # Update progress
  def update_progress!
    update(progress_percentage: calculate_progress)
  end

  private

  def organizer_can_create_tournament
    unless organizer_can_create_tournament?
      errors.add(:organizer, "프리미엄 회원만 대회를 개최할 수 있습니다")
    end
  end

  def set_tournament_attributes
    self.created_by_premium_user = organizer.is_premium? unless is_official?
    self.can_create_tournaments = true if organizer.is_premium?
  end

  def setup_automations
    return if is_official? # BDR 공식 대회는 수동 관리

    # 자동화 서비스 호출 (백그라운드 잡)
    TournamentAutomationSetupJob.perform_later(self)
  rescue => e
    Rails.logger.error "Failed to setup tournament automations: #{e.message}"
  end
  
  def create_default_checklists
    TournamentChecklist.create_default_checklists_for(self)
  end

  def generate_tournament_code
    return if tournament_code.present?

    year = tournament_start_at&.year || Time.current.year
    month = tournament_start_at&.month || Time.current.month

    # 대회 타입 코드
    type_code = case tournament_type
    when "single_elimination" then "SE"
    when "double_elimination" then "DE"
    when "round_robin" then "RR"
    when "group_stage" then "GS"
    else "OT"
    end

    # 같은 년월의 대회 수
    base_date = Date.new(year, month, 1)
    count = Tournament.where("tournament_start_at >= ? AND tournament_start_at < ?",
                           base_date, base_date.next_month).count

    # 대회 코드 형식
    # BDR 공식: BDR + 년도(4자리) + 월(2자리) + 타입(2자리) + 순번(3자리)
    # 사용자 주최: USR + 년도(4자리) + 월(2자리) + 타입(2자리) + 순번(3자리)
    prefix = is_official? ? "BDR" : "USR"
    self.tournament_code = "#{prefix}#{year}#{month.to_s.rjust(2, '0')}#{type_code}#{(count + 1).to_s.rjust(3, '0')}"
  end

  def validate_images_count
    return unless images.attached?

    if images.count > 5
      errors.add(:images, "는 최대 5장까지만 업로드할 수 있습니다.")
    end
  end

  # 메인 이미지 반환 (첫 번째 이미지 또는 지정된 위치의 이미지)
  def main_image
    return nil unless images.attached?

    if main_image_position && images[main_image_position]
      images[main_image_position]
    else
      images.first
    end
  end

  # 이미지 순서 변경
  def reorder_images(new_order)
    return unless images.attached? && new_order.is_a?(Array)

    # 새로운 순서로 이미지 재정렬
    reordered = new_order.map { |id| images.find { |img| img.id == id.to_i } }.compact

    # 기존 이미지 분리하고 새 순서로 다시 붙이기
    images.detach
    reordered.each { |img| images.attach(img.blob) }
  end
end
