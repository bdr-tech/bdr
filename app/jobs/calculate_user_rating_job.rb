class CalculateUserRatingJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find_by(id: game_id)
    return unless game

    # 경기에 참가한 모든 사용자들의 평점 계산
    game.all_participants.each do |user|
      calculate_rating_for_user(user, game)
    end

    Rails.logger.info "Calculated ratings for all participants in game #{game_id}"
  rescue => e
    Rails.logger.error "Failed to calculate ratings for game #{game_id}: #{e.message}"
  end

  private

  def calculate_rating_for_user(user, game)
    # 해당 경기에서 받은 평가들
    evaluations = user.received_evaluations.for_game(game).completed
    return if evaluations.empty?

    # 긍정적/부정적 평가 계산
    positive_count = 0
    negative_count = 0

    evaluations.each do |eval|
      avg_score = eval.average_score
      if avg_score >= 3.5  # 3.5점 이상은 긍정적
        positive_count += 1
      elsif avg_score < 2.5  # 2.5점 미만은 부정적
        negative_count += 1
      end
      # 2.5 ~ 3.5는 중립으로 처리 (변동 없음)
    end

    # 평점 변동 계산 (0.1 단위)
    rating_change = (positive_count * 0.1) - (negative_count * 0.1)

    # 현재 평점
    current_rating = user.evaluation_rating || 50.0
    new_rating = current_rating + rating_change

    # 평점 범위 제한 (0 ~ 100)
    new_rating = [ [ new_rating, 0.0 ].max, 100.0 ].min

    # 평점 업데이트 및 기록
    ActiveRecord::Base.transaction do
      user.update!(evaluation_rating: new_rating)

      UserRatingHistory.create!(
        user: user,
        game: game,
        rating_before: current_rating,
        rating_after: new_rating,
        rating_change: rating_change,
        change_reason: "경기 평가 완료",
        evaluation_count: evaluations.count,
        positive_count: positive_count,
        negative_count: negative_count
      )

      # 평점 변동 알림
      if rating_change != 0
        notify_rating_change(user, rating_change, new_rating)
      end
    end
  end

  def notify_rating_change(user, rating_change, new_rating)
    change_text = rating_change > 0 ? "+#{rating_change}" : rating_change.to_s
    emoji = rating_change > 0 ? "📈" : "📉"

    Notification.create_for_user(
      user,
      "rating_updated",
      {
        title: "#{emoji} 평점이 업데이트되었습니다",
        message: "평점이 #{change_text}% 변동되어 현재 #{new_rating}%입니다.",
        priority: "normal",
        data: {
          rating_change: rating_change,
          new_rating: new_rating
        }
      }
    )
  end
end
