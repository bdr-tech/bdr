class CloseGameApplicationsJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    game = Game.find_by(id: game_id)
    return unless game
    return if game.status.in?([ "cancelled", "completed", "closed" ])

    # 경기 시작 시간이 되었는지 확인
    return if game.scheduled_at > Time.current

    ActiveRecord::Base.transaction do
      # 경기 신청 마감 처리
      game.update!(status: "closed")

      # 대기중인 신청들 모두 거절 처리
      pending_applications = game.game_applications.pending
      pending_applications.each do |application|
        application.reject!

        # 거절 알림 전송
        Notification.create_for_user(
          application.user,
          "game_application_rejected",
          {
            title: "경기 마감으로 인한 신청 거절",
            message: "#{game.title} 경기가 시작되어 신청이 자동으로 거절되었습니다.",
            notifiable: game,
            priority: "normal"
          }
        )
      end

      # 최종 참가 인원 수 기록
      final_player_count = game.confirmed_players_count
      game.update!(
        final_player_count: final_player_count,
        closed_at: Time.current
      )

      # 호스트에게 마감 알림 전송
      Notification.create_for_user(
        game.organizer,
        "game_closed",
        {
          title: "경기가 마감되었습니다",
          message: "#{game.title} 경기가 시작되어 자동 마감되었습니다. 최종 참가 인원: #{final_player_count}명",
          notifiable: game,
          priority: "high",
          data: {
            final_player_count: final_player_count,
            expected_revenue: game.fee * final_player_count
          }
        }
      )

      # 부분 정산 처리 (인원수가 부족한 경우)
      if final_player_count < game.max_players
        process_partial_settlement(game, final_player_count)
      end
    end

    Rails.logger.info "Closed game applications for game #{game_id}, final count: #{game.final_player_count}"
  rescue => e
    Rails.logger.error "Failed to close game applications for game #{game_id}: #{e.message}"
  end

  private

  def process_partial_settlement(game, final_player_count)
    # 실제 수익 계산
    actual_revenue = game.fee * final_player_count
    platform_fee = (actual_revenue * game.current_platform_fee_percentage / 100).round(0)
    host_revenue = actual_revenue - platform_fee

    # 정산 정보 업데이트
    game.update!(
      actual_revenue: actual_revenue,
      actual_platform_fee: platform_fee,
      actual_host_revenue: host_revenue,
      is_partial_settlement: true
    )

    # 호스트에게 부분 정산 알림
    Notification.create_for_user(
      game.organizer,
      "partial_settlement",
      {
        title: "부분 정산 안내",
        message: "인원 미달로 #{final_player_count}명 기준으로 정산됩니다. 예상 수익: #{number_to_currency(host_revenue, unit: '', precision: 0)}원",
        notifiable: game,
        priority: "high",
        data: {
          final_player_count: final_player_count,
          actual_revenue: actual_revenue,
          platform_fee: platform_fee,
          host_revenue: host_revenue
        }
      }
    )
  end

  def number_to_currency(number, options = {})
    ActionController::Base.helpers.number_to_currency(number, options)
  end
end
