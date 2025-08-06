class SendGameReminderJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find_by(id: game_id)
    return unless game
    return if game.status == "cancelled"

    # 경기 시작 시간 계산
    game_time = game.scheduled_at
    time_until_game = game_time - Time.current

    # 이미 경기가 시작했거나 취소된 경우 중단
    return if time_until_game < 0

    # 모든 최종 승인된 참가자들에게 리마인더 전송
    participants = game.confirmed_players

    participants.each do |participant|
      Notification.create!(
        user: participant,
        title: "🏀 경기 리마인더",
        message: "#{format_time_until(time_until_game)} 후에 #{game.title} 경기가 시작됩니다! 준비하세요!",
        notification_type: "game_reminder",
        notifiable: game,
        priority: "high",
        data: {
          game_id: game.id,
          game_title: game.title,
          game_time: game_time,
          venue: game.venue_name,
          address: game.venue_address
        }
      )
    end

    Rails.logger.info "Sent game reminders for game #{game_id} to #{participants.count} participants"
  rescue => e
    Rails.logger.error "Failed to send game reminders for game #{game_id}: #{e.message}"
  end

  private

  def format_time_until(seconds)
    hours = (seconds / 3600).to_i
    minutes = ((seconds % 3600) / 60).to_i

    if hours > 0
      "#{hours}시간 #{minutes}분"
    else
      "#{minutes}분"
    end
  end
end
