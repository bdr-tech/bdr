class MarkGameCompletedJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find_by(id: game_id)
    return unless game
    return if game.status == "cancelled" || game.status == "completed"

    # 경기 종료 시간이 지났는지 확인
    end_time = game.end_time || (game.scheduled_at + 2.hours)
    return if end_time > Time.current

    # 경기 상태를 완료로 변경
    game.update!(status: "completed")

    # 모든 참가자에게 경기 완료 알림 전송
    game.all_participants.each do |participant|
      Notification.create!(
        user: participant,
        title: "🏀 경기가 종료되었습니다",
        message: "#{game.title} 경기가 종료되었습니다. 수고하셨습니다!",
        notification_type: "game_completed",
        notifiable: game,
        priority: "normal",
        data: {
          game_id: game.id,
          game_title: game.title
        }
      )
    end

    Rails.logger.info "Marked game #{game_id} as completed and sent notifications"
  rescue => e
    Rails.logger.error "Failed to mark game #{game_id} as completed: #{e.message}"
  end
end
