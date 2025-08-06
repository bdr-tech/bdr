class CloseEvaluationJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find_by(id: game_id)
    return unless game

    # 평가 마감 처리
    evaluation_deadline = game.evaluation_deadline
    return unless evaluation_deadline

    evaluation_deadline.update!(is_active: false)

    # 평가를 완료하지 않은 참가자들에게 알림
    unevaluated_participants = game.all_participants.select do |participant|
      # 해당 경기에서 평가를 하나도 하지 않은 참가자 찾기
      !PlayerEvaluation.exists?(
        game: game,
        evaluator_type: participant.class.name,
        evaluator_id: participant.id
      )
    end

    unevaluated_participants.each do |participant|
      Notification.create!(
        user: participant,
        title: "⏰ 평가 기간이 종료되었습니다",
        message: "#{game.title} 경기의 평가 기간이 종료되었습니다. 다음에는 꼭 동료들을 평가해주세요!",
        notification_type: "evaluation_closed",
        data: {
          game_id: game.id,
          game_title: game.title
        }
      )
    end

    # 주최자에게 평가 완료 통계 알림
    total_participants = game.all_participants.count
    evaluations_count = PlayerEvaluation.where(game: game).count
    participation_rate = total_participants > 0 ? (evaluations_count.to_f / (total_participants * (total_participants - 1)) * 100).round(1) : 0

    Notification.create!(
      user: game.organizer,
      title: "📊 평가 기간이 종료되었습니다",
      message: "#{game.title} 경기의 평가가 마감되었습니다. 평가 참여율: #{participation_rate}%",
      notification_type: "evaluation_summary",
      data: {
        game_id: game.id,
        game_title: game.title,
        total_evaluations: evaluations_count,
        participation_rate: participation_rate
      }
    )

    # 평점 계산 Job 실행
    CalculateUserRatingJob.perform_later(game_id)

    Rails.logger.info "Closed evaluations for game #{game_id}"
  rescue => e
    Rails.logger.error "Failed to close evaluations for game #{game_id}: #{e.message}"
  end
end
