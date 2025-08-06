class SendEvaluationReminderJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find_by(id: game_id)
    return unless game

    # 평가 마감 시간 생성
    game.create_evaluation_deadline!

    # 모든 참가자에게 평가 알림 전송
    game.all_participants.each do |participant|
      Notification.create!(
        user: participant,
        title: "🌟 경기 평가를 해주세요!",
        message: "기억에 남는 동료 선수에 대한 평가를 남겨주세요. #{game.title} 경기의 평가가 24시간 후 마감됩니다.",
        notification_type: "evaluation_reminder",
        data: {
          game_id: game.id,
          game_title: game.title,
          deadline: game.evaluation_deadline.deadline
        }
      )
    end

    # 24시간 후 평가 종료 Job 예약
    CloseEvaluationJob.set(wait: 24.hours).perform_later(game_id)
  rescue => e
    Rails.logger.error "Failed to send evaluation reminders for game #{game_id}: #{e.message}"
  end
end
