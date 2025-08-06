class TournamentChecklist < ApplicationRecord
  belongs_to :tournament
  
  # Phases
  PHASES = %w[day_before game_day post_game].freeze
  
  # Validations
  validates :phase, presence: true, inclusion: { in: PHASES }
  validates :task_name, presence: true
  
  # Scopes
  scope :by_phase, ->(phase) { where(phase: phase) }
  scope :pending, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :automated, -> { where(automated: true) }
  scope :manual, -> { where(automated: false) }
  scope :by_priority, -> { order(priority: :desc, created_at: :asc) }
  
  # Mark as completed
  def complete!
    update!(completed: true, completed_at: Time.current)
  end
  
  # Mark as incomplete
  def uncomplete!
    update!(completed: false, completed_at: nil)
  end
  
  # Check if overdue
  def overdue?
    return false if completed?
    
    case phase
    when "day_before"
      tournament.tournament_start_at && tournament.tournament_start_at < 1.day.from_now
    when "game_day"
      tournament.tournament_start_at && tournament.tournament_start_at < Time.current
    when "post_game"
      tournament.tournament_end_at && tournament.tournament_end_at < 1.day.ago
    else
      false
    end
  end
  
  # Execute automated task
  def execute_automated_task
    return unless automated?
    
    case task_name
    when "send_reminder_messages"
      send_reminder_messages
    when "publish_brackets"
      publish_brackets
    when "check_weather"
      check_weather_and_notify
    when "generate_qr_codes"
      generate_qr_codes
    else
      Rails.logger.info "Unknown automated task: #{task_name}"
    end
    
    complete!
  end
  
  private
  
  def send_reminder_messages
    tournament.approved_teams.each do |team|
      # Send notification to team captain
      Notification.create!(
        user: team.captain,
        notification_type: "tournament_reminder",
        related_id: tournament.id,
        related_type: "Tournament",
        content: "내일 #{tournament.name} 대회가 있습니다. 준비해주세요!"
      )
    end
  end
  
  def publish_brackets
    # Generate and publish tournament brackets
    BracketGenerationService.new(tournament).generate_and_publish
  end
  
  def check_weather_and_notify
    # Check weather and send notification if needed
    WeatherCheckService.new(tournament).check_and_notify
  end
  
  def generate_qr_codes
    tournament.tournament_teams.approved.each do |team|
      team.generate_qr_token! if team.qr_token.blank?
    end
  end
  
  # Class method to create default checklists for a tournament
  def self.create_default_checklists_for(tournament)
    # Day before checklist
    [
      { phase: "day_before", task_name: "send_reminder_messages", description: "참가자 리마인더 발송", priority: 10, automated: true },
      { phase: "day_before", task_name: "publish_brackets", description: "대진표 공개", priority: 9, automated: true },
      { phase: "day_before", task_name: "check_weather", description: "날씨 확인 및 알림", priority: 8, automated: true },
      { phase: "day_before", task_name: "prepare_equipment", description: "장비 준비 확인", priority: 7, automated: false },
      
      # Game day checklist
      { phase: "game_day", task_name: "generate_qr_codes", description: "QR 코드 생성", priority: 10, automated: true },
      { phase: "game_day", task_name: "setup_venue", description: "경기장 세팅", priority: 9, automated: false },
      { phase: "game_day", task_name: "check_in_teams", description: "팀 체크인", priority: 8, automated: false },
      { phase: "game_day", task_name: "referee_briefing", description: "심판 브리핑", priority: 7, automated: false },
      
      # Post game checklist
      { phase: "post_game", task_name: "collect_results", description: "경기 결과 수집", priority: 10, automated: false },
      { phase: "post_game", task_name: "distribute_prizes", description: "상금 배분", priority: 9, automated: false },
      { phase: "post_game", task_name: "send_thank_you", description: "감사 메시지 발송", priority: 8, automated: true },
      { phase: "post_game", task_name: "cleanup_venue", description: "경기장 정리", priority: 7, automated: false }
    ].each do |checklist_params|
      tournament.tournament_checklists.create!(checklist_params)
    end
  end
end