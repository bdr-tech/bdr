class MatchPoolProcessingJob < ApplicationJob
  queue_as :default

  def perform(match_pool_id)
    match_pool = MatchPool.find(match_pool_id)
    return unless match_pool.status == "forming"

    # 최소 인원 확인
    if match_pool.current_players >= match_pool.min_players
      create_game_from_pool(match_pool)
    elsif match_pool.match_time <= 1.hour.from_now
      # 경기 시작 1시간 전까지 최소 인원 미달 시 취소
      cancel_match_pool(match_pool)
    else
      # 아직 시간이 남았으면 나중에 다시 확인
      MatchPoolProcessingJob.set(wait: 30.minutes).perform_later(match_pool_id)
    end
  end

  private

  def create_game_from_pool(match_pool)
    ActiveRecord::Base.transaction do
      # 적합한 코트 찾기 (지역 기반)
      court = find_suitable_court(match_pool)

      # 경기 생성
      game = Game.create!(
        host: select_host_from_participants(match_pool),
        court: court,
        scheduled_at: match_pool.match_time,
        game_type: match_pool.game_type,
        required_skill_level: match_pool.skill_level,
        min_players: match_pool.min_players,
        max_players: match_pool.max_players,
        fee_per_person: calculate_fee_per_person(court),
        description: "퀵매치로 자동 생성된 경기입니다.",
        status: "confirmed",
        quick_match_generated: true
      )

      # 참가자들을 경기에 추가
      match_pool.match_pool_participants.where(status: "waiting").each do |participant|
        GameParticipation.create!(
          game: game,
          user: participant.user,
          status: "confirmed",
          confirmed_at: Time.current
        )

        # 참가자에게 알림
        Notification.create!(
          user: participant.user,
          notification_type: "quick_match_game_created",
          related: game,
          content: "퀵매치 경기가 생성되었습니다. #{game.scheduled_at.strftime('%m월 %d일 %H시')} #{court.name}"
        )
      end

      # 매치 풀 상태 업데이트
      match_pool.update!(
        status: "game_created",
        created_game: game
      )

      # 퀵매치 기록 업데이트
      QuickMatchHistory.where(match_pool: match_pool).update_all(
        game_id: game.id,
        successful: true
      )
    end
  end

  def cancel_match_pool(match_pool)
    ActiveRecord::Base.transaction do
      # 참가자들에게 취소 알림
      match_pool.match_pool_participants.where(status: "waiting").each do |participant|
        Notification.create!(
          user: participant.user,
          notification_type: "quick_match_cancelled",
          related_type: "MatchPool",
          related_id: match_pool.id,
          content: "퀵매치가 최소 인원 부족으로 취소되었습니다."
        )
      end

      # 매치 풀 상태 업데이트
      match_pool.update!(status: "cancelled")

      # 퀵매치 기록 업데이트
      QuickMatchHistory.where(match_pool: match_pool).update_all(
        successful: false
      )
    end
  end

  def find_suitable_court(match_pool)
    # 지역 기반 코트 찾기
    courts = Court.where(city: match_pool.city)
    courts = courts.where(district: match_pool.district) if match_pool.district.present?

    # 해당 시간대에 예약 가능한 코트 찾기
    available_courts = courts.select do |court|
      !Game.where(court: court)
           .where("scheduled_at BETWEEN ? AND ?",
                  match_pool.match_time - 2.hours,
                  match_pool.match_time + 2.hours)
           .exists?
    end

    # 가장 적합한 코트 선택 (평점 높은 순)
    available_courts.max_by { |c| c.average_rating || 0 } || courts.first
  end

  def select_host_from_participants(match_pool)
    participants = match_pool.match_pool_participants.includes(:user)

    # 호스트 경험이 많은 사용자 우선
    experienced_hosts = participants.map(&:user).select { |u| u.games_as_host.count > 0 }

    if experienced_hosts.any?
      experienced_hosts.max_by { |u| u.games_as_host.count }
    else
      # 프리미엄 사용자 우선
      premium_users = participants.map(&:user).select(&:is_premium?)
      premium_users.first || participants.first.user
    end
  end

  def calculate_fee_per_person(court)
    # 코트 대관료를 참가 인원으로 나눈 금액 + 플랫폼 수수료
    base_fee = court.hourly_rate.to_f / 10  # 10명 기준
    (base_fee * 1.05).round(-2)  # 5% 플랫폼 수수료 포함, 100원 단위로 반올림
  end
end
