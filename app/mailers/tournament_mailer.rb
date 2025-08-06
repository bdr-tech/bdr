class TournamentMailer < ApplicationMailer
  default from: 'noreply@bdr.com'
  
  def reminder(user, tournament, message)
    @user = user
    @tournament = tournament
    @message = message
    
    mail(
      to: @user.email,
      subject: "[BDR] #{@tournament.name} - 리마인더"
    )
  end
  
  def campaign_email(user, tournament, template)
    @user = user
    @tournament = tournament
    @template = template
    
    subject = case template
    when 'tournament_announcement'
      "🏀 새로운 대회 안내"
    when 'registration_open'
      "📝 대회 등록 시작!"
    when 'deadline_reminder'
      "⏰ 등록 마감 임박"
    when 'final_call'
      "🚨 최종 등록 기회"
    when 'tournament_reminder'
      "📅 대회 일정 안내"
    when 'game_day_reminder'
      "🎯 오늘 대회가 있습니다!"
    else
      "BDR 대회 안내"
    end
    
    mail(
      to: @user.email,
      subject: "[BDR] #{@tournament.name} - #{subject}"
    )
  end
end