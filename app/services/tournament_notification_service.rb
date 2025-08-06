class TournamentNotificationService
  def initialize(tournament)
    @tournament = tournament
  end

  # 리마인더 전송 (테스트용)
  def send_reminder(message = nil)
    message ||= "대회가 곧 시작됩니다!"
    send_announcement(message, :all)
  end

  # 대회 공지사항 전송
  def send_announcement(message, recipients = :all)
    users = case recipients
    when :all
              get_all_participants
    when :players
              get_players
    when :organizers
              [ @tournament.organizer ]
    else
              recipients
    end

    users.each do |user|
      create_notification(user, "announcement", message)
    end

    # 실시간 업데이트
    @tournament.tournament_live_updates.create!(
      user: @tournament.organizer,
      update_type: "announcement",
      data: { message: message },
      is_official: true
    )
  end

  # 경기 시작 알림
  def notify_match_start(match, minutes_before = 30)
    teams = [ match.team_a, match.team_b ].compact

    teams.each do |team|
      team.tournament_players.each do |player|
        message = "#{minutes_before}분 후 경기가 시작됩니다! 코트 #{match.court_number}번으로 이동해주세요."

        create_notification(
          player.user,
          "match_reminder",
          message,
          { match_id: match.id, team_id: team.id }
        )

        # SMS 발송 (중요 알림)
        send_sms(player.user, message) if player.user.sms_notifications?
      end
    end
  end

  # 경기 준비 알림
  def notify_match_ready(match)
    message = "다음 경기가 확정되었습니다: #{match.team_a.name} vs #{match.team_b.name}"

    [ match.team_a, match.team_b ].each do |team|
      team.tournament_players.each do |player|
        create_notification(
          player.user,
          "match_scheduled",
          message,
          { match_id: match.id }
        )
      end
    end
  end

  # 대회 발행 알림
  def notify_tournament_published
    message = "🏀 새로운 대회가 열렸습니다! '#{@tournament.name}' - 지금 바로 참가 신청하세요!"

    # 관심 지역 사용자에게 알림
    interested_users = User.where(city: @tournament.venue_city)
                          .where(push_notifications: true)

    interested_users.find_each do |user|
      create_notification(user, "new_tournament", message)
    end
  end

  # 일정 변경 알림
  def notify_schedule_change(match, old_time, new_time)
    message = "경기 일정이 변경되었습니다. #{old_time.strftime('%H:%M')} → #{new_time.strftime('%H:%M')}"

    [ match.team_a, match.team_b ].compact.each do |team|
      team.tournament_players.each do |player|
        create_notification(
          player.user,
          "schedule_change",
          message,
          { match_id: match.id, old_time: old_time, new_time: new_time }
        )
      end
    end
  end

  # 결과 알림
  def notify_match_result(match)
    winner = match.winner
    loser = match.team_a == winner ? match.team_b : match.team_a

    # 승리팀 알림
    winner.tournament_players.each do |player|
      create_notification(
        player.user,
        "match_won",
        "축하합니다! #{loser.name}을(를) 이기고 다음 라운드에 진출했습니다! 🎉"
      )
    end

    # 패배팀 알림
    loser.tournament_players.each do |player|
      create_notification(
        player.user,
        "match_lost",
        "수고하셨습니다. 다음 기회에 다시 도전해주세요! 💪"
      )
    end
  end

  # 대회 종료 알림
  def notify_tournament_completed
    winner = @tournament.tournament_teams.find_by(final_rank: 1)

    message = "🏆 #{@tournament.name}이(가) 종료되었습니다! 우승: #{winner&.name}"

    get_all_participants.each do |user|
      create_notification(user, "tournament_completed", message)
    end
  end

  private

  def get_all_participants
    User.joins(tournament_players: { tournament_team: :tournament })
        .where(tournament_teams: { tournament_id: @tournament.id })
        .distinct
  end

  def get_players
    get_all_participants
  end

  def create_notification(user, notification_type, message, data = {})
    notification = user.notifications.create!(
      notification_type: notification_type,
      title: notification_title(notification_type),
      message: message,
      data: data.merge(tournament_id: @tournament.id),
      source_type: "Tournament",
      source_id: @tournament.id
    )

    # ActionCable로 실시간 전송
    broadcast_notification(user, notification)

    # 푸시 알림
    send_push_notification(user, notification) if user.push_notifications?

    notification
  end

  def notification_title(type)
    titles = {
      "announcement" => "📢 대회 공지",
      "match_reminder" => "⏰ 경기 알림",
      "match_scheduled" => "📅 경기 확정",
      "new_tournament" => "🏀 새 대회",
      "schedule_change" => "🔄 일정 변경",
      "match_won" => "🎉 승리",
      "match_lost" => "💪 패배",
      "tournament_completed" => "🏆 대회 종료"
    }
    titles[type] || "알림"
  end

  def broadcast_notification(user, notification)
    NotificationChannel.broadcast_to(
      user,
      {
        id: notification.id,
        title: notification.title,
        message: notification.message,
        created_at: notification.created_at
      }
    )
  end

  def send_push_notification(user, notification)
    # FCM이나 기타 푸시 서비스 연동
    # PushNotificationJob.perform_later(user.id, notification.id)
  end

  def send_sms(user, message)
    # SMS 서비스 연동
    # SmsService.new.send(user.phone, message) if user.phone.present?
  end
end
