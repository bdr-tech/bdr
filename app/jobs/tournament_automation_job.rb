class TournamentAutomationJob < ApplicationJob
  queue_as :default

  def perform
    # 예정된 자동화 작업 찾기
    pending_automations = TournamentAutomation
      .where(status: "scheduled")
      .where("scheduled_at <= ?", Time.current)
      .includes(:tournament)

    pending_automations.each do |automation|
      begin
        automation.update!(status: "processing")
        TournamentAutomationService.execute_automation(automation)
      rescue => e
        automation.update!(
          status: "failed",
          execution_log: e.message
        )
        Rails.logger.error "Tournament Automation Failed: #{e.message}"
      end
    end
  end
end
