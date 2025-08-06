class TournamentReminderJob < ApplicationJob
  queue_as :default
  
  def perform(team)
    tournament = team.tournament
    
    # Send reminder to team captain
    NotificationAdapter.create_tournament_notification(
      user: team.captain,
      tournament: tournament,
      type: 'tournament_reminder',
      content: "#{tournament.name} 대회 리마인더입니다."
    )
    
    # Send email if enabled
    if team.captain.email.present?
      TournamentMailer.reminder(
        team.captain,
        tournament,
        "대회가 곧 시작됩니다. 준비해주세요!"
      ).deliver_later
    end
  end
end