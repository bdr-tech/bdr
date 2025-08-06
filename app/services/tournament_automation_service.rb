class TournamentAutomationService
  def self.setup_for(tournament)
    return if tournament.is_official? # BDR 공식 대회는 수동 관리

    new(tournament).setup_all_automations
  end

  def initialize(tournament)
    @tournament = tournament
  end

  def setup_all_automations
    # 1. 마케팅 캠페인 스케줄링
    schedule_marketing_campaigns

    # 2. 대진표 자동 생성 스케줄링
    schedule_bracket_generation

    # 3. 결과 처리 자동화 설정
    setup_result_automation

    # 4. 정산 자동화 설정
    setup_settlement_automation

    # 5. AI 포스터 생성 (템플릿 사용 시)
    generate_ai_poster if @tournament.template_used.present?
  end

  private

  def schedule_marketing_campaigns
    return unless @tournament.auto_notification_enabled

    campaign_schedule = calculate_campaign_schedule

    campaign_schedule.each do |campaign|
      TournamentAutomation.create!(
        tournament: @tournament,
        automation_type: "marketing_campaign",
        status: "scheduled",
        scheduled_at: campaign[:date],
        configuration: {
          campaign_type: campaign[:type],
          channels: campaign[:channels],
          template: campaign[:template]
        }
      )
    end
  end

  def calculate_campaign_schedule
    registration_start = @tournament.registration_start_at
    registration_end = @tournament.registration_end_at
    tournament_start = @tournament.tournament_start_at

    campaigns = []

    # D-30: 대회 공지
    if registration_start > 30.days.from_now
      campaigns << {
        date: tournament_start - 30.days,
        type: "announcement",
        channels: [ "email", "push" ],
        template: "tournament_announcement"
      }
    end

    # 등록 시작일: 등록 오픈 알림
    campaigns << {
      date: registration_start,
      type: "registration_open",
      channels: [ "email", "push", "sms" ],
      template: "registration_open"
    }

    # 등록 마감 3일 전: 마감 임박 알림
    if registration_end - registration_start > 3.days
      campaigns << {
        date: registration_end - 3.days,
        type: "deadline_reminder",
        channels: [ "email", "push" ],
        template: "deadline_reminder"
      }
    end

    # 등록 마감 1일 전: 최종 알림
    campaigns << {
      date: registration_end - 1.day,
      type: "final_call",
      channels: [ "push", "sms" ],
      template: "final_call"
    }

    # 대회 3일 전: 대회 안내
    campaigns << {
      date: tournament_start - 3.days,
      type: "tournament_reminder",
      channels: [ "email", "push" ],
      template: "tournament_reminder"
    }

    # 대회 당일 아침: 최종 안내
    campaigns << {
      date: tournament_start.change(hour: 8),
      type: "game_day",
      channels: [ "push", "sms" ],
      template: "game_day_reminder"
    }

    campaigns.select { |c| c[:date] > Time.current }
  end

  def schedule_bracket_generation
    return unless @tournament.auto_bracket_generated

    # 등록 마감 30분 후 대진표 자동 생성
    TournamentAutomation.create!(
      tournament: @tournament,
      automation_type: "bracket_generation",
      status: "scheduled",
      scheduled_at: @tournament.registration_end_at + 30.minutes,
      configuration: {
        seeding_method: "skill_based",
        bracket_type: @tournament.tournament_type,
        notify_participants: true
      }
    )
  end

  def setup_result_automation
    # 각 경기 종료 예정 시간에 결과 입력 요청
    TournamentAutomation.create!(
      tournament: @tournament,
      automation_type: "result_processing",
      status: "scheduled",
      scheduled_at: @tournament.tournament_end_at,
      configuration: {
        auto_calculate_standings: true,
        generate_certificates: true,
        send_results_notification: true
      }
    )
  end

  def setup_settlement_automation
    # 대회 종료 1일 후 자동 정산
    TournamentAutomation.create!(
      tournament: @tournament,
      automation_type: "settlement_processing",
      status: "scheduled",
      scheduled_at: @tournament.tournament_end_at + 1.day,
      configuration: {
        calculate_platform_fee: true,
        distribute_prizes: true,
        generate_financial_report: true
      }
    )
  end

  def generate_ai_poster
    # AI 포스터 생성 작업을 백그라운드로 실행
    AIPosterGenerationJob.perform_later(@tournament.id)
  end

  # 자동화 실행 메서드들
  def self.execute_automation(automation)
    case automation.automation_type
    when "marketing_campaign"
      execute_marketing_campaign(automation)
    when "bracket_generation"
      execute_bracket_generation(automation)
    when "result_processing"
      execute_result_processing(automation)
    when "settlement_processing"
      execute_settlement_processing(automation)
    end
  end

  def self.execute_marketing_campaign(automation)
    tournament = automation.tournament
    config = automation.configuration

    # 대상자 선정
    recipients = case config["campaign_type"]
    when "announcement"
                   User.where(marketing_consent: true)
    when "registration_open"
                   User.joins(:quick_match_preference)
                       .where(quick_match_preferences: { auto_match_enabled: true })
    when "deadline_reminder", "final_call"
                   # 아직 등록하지 않은 관심 사용자
                   User.where.not(id: tournament.tournament_teams.joins(:players).select("users.id"))
                       .where(is_premium: true)
    when "tournament_reminder", "game_day"
                   # 참가 확정자
                   User.joins(tournament_teams: :tournament)
                       .where(tournament_teams: { tournament_id: tournament.id, status: "approved" })
    else
                   User.none
    end

    # 캠페인 발송
    campaign = TournamentMarketingCampaign.create!(
      tournament: tournament,
      campaign_type: config["campaign_type"],
      channel: config["channels"].first, # 주 채널
      recipients_count: recipients.count,
      content: {
        template: config["template"],
        channels: config["channels"]
      }
    )

    # 각 채널별 발송
    config["channels"].each do |channel|
      case channel
      when "email"
        recipients.find_each do |user|
          TournamentMailer.campaign_email(user, tournament, config["template"]).deliver_later
        end
      when "push"
        # 푸시 알림 발송 로직
        NotificationService.send_bulk_push(recipients, tournament, config["template"])
      when "sms"
        # SMS 발송 로직 (외부 서비스 연동)
        SMSService.send_bulk(recipients, tournament, config["template"])
      end
    end

    campaign.update!(sent_at: Time.current)
    automation.update!(status: "completed", executed_at: Time.current)
  end

  def self.execute_bracket_generation(automation)
    tournament = automation.tournament
    config = automation.configuration

    # 승인된 팀들로 대진표 생성
    approved_teams = tournament.tournament_teams.approved

    bracket_service = BracketGenerationService.new(tournament)
    bracket = bracket_service.generate(
      teams: approved_teams,
      seeding_method: config["seeding_method"],
      bracket_type: config["bracket_type"]
    )

    # 참가자들에게 대진표 알림
    if config["notify_participants"]
      approved_teams.each do |team|
        team.players.each do |player|
          Notification.create!(
            user: player,
            notification_type: "tournament_bracket_ready",
            related_id: tournament.id,
            related_type: "Tournament",
            content: "#{tournament.name} 대진표가 확정되었습니다."
          )
        end
      end
    end

    automation.update!(
      status: "completed",
      executed_at: Time.current,
      execution_log: "대진표 생성 완료: #{approved_teams.count}팀"
    )
  end

  def self.execute_result_processing(automation)
    tournament = automation.tournament

    # 모든 경기 결과 확인 및 집계
    ResultProcessingService.new(tournament).process_all

    # 최종 순위 계산
    StandingsCalculationService.new(tournament).calculate

    # 참가 인증서 생성
    if automation.configuration["generate_certificates"]
      CertificateGenerationService.new(tournament).generate_all
    end

    # 결과 알림 발송
    if automation.configuration["send_results_notification"]
      NotificationService.send_tournament_results(tournament)
    end

    automation.update!(status: "completed", executed_at: Time.current)
  end

  def self.execute_settlement_processing(automation)
    tournament = automation.tournament

    # 플랫폼 수수료 계산
    platform_fee = tournament.calculate_platform_fee
    tournament.update!(
      actual_platform_fee: platform_fee,
      settlement_status: "processing"
    )

    # 상금 분배
    if automation.configuration["distribute_prizes"]
      PrizeDistributionService.new(tournament).distribute
    end

    # 재무 보고서 생성
    if automation.configuration["generate_financial_report"]
      FinancialReportService.new(tournament).generate
    end

    tournament.update!(
      settlement_status: "completed",
      settlement_completed_at: Time.current
    )

    automation.update!(status: "completed", executed_at: Time.current)
  end
end
