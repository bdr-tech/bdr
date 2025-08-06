class TournamentNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(tournament_id, notification_type, options = {})
    tournament = Tournament.find(tournament_id)
    notification_service = TournamentNotificationService.new(tournament)

    case notification_type
    when "published"
      notification_service.notify_tournament_published
    when "match_reminder"
      match = tournament.tournament_matches.find(options[:match_id])
      notification_service.notify_match_start(match, options[:minutes_before] || 30)
    when "match_result"
      match = tournament.tournament_matches.find(options[:match_id])
      notification_service.notify_match_result(match)
    when "tournament_completed"
      notification_service.notify_tournament_completed
    when "announcement"
      notification_service.send_announcement(options[:message], options[:recipients])
    end
  rescue => e
    Rails.logger.error "대회 알림 발송 실패: #{e.message}"
  end
end
