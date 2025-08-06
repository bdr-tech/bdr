class TournamentPosterJob < ApplicationJob
  queue_as :default

  def perform(tournament_id, template = nil)
    tournament = Tournament.find(tournament_id)

    # 포스터 생성
    poster_service = TournamentPosterService.new(tournament, template)
    poster_url = poster_service.generate

    # 미디어 레코드 생성
    tournament.tournament_media.create!(
      user: tournament.organizer,
      media_type: "poster",
      title: "#{tournament.name} 공식 포스터",
      description: "자동 생성된 대회 포스터",
      file_url: poster_url,
      metadata: {
        auto_generated: true,
        template: template
      }
    )

    # 알림 발송
    tournament.organizer.notifications.create!(
      notification_type: "poster_generated",
      title: "포스터 생성 완료",
      message: "대회 포스터가 생성되었습니다. 확인해보세요!",
      source_type: "Tournament",
      source_id: tournament.id
    )
  rescue => e
    Rails.logger.error "포스터 생성 실패: #{e.message}"

    # 실패 알림
    tournament.organizer.notifications.create!(
      notification_type: "poster_generation_failed",
      title: "포스터 생성 실패",
      message: "포스터 생성 중 오류가 발생했습니다. 다시 시도해주세요.",
      source_type: "Tournament",
      source_id: tournament.id
    )
  end
end
