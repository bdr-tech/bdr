class TournamentDashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament
  before_action :check_organizer_permission
  
  def show
    # Use includes to prevent N+1 queries
    @tournament = Tournament.includes(
      :tournament_teams, 
      :tournament_matches,
      :tournament_checklists
    ).find(params[:tournament_id] || params[:id])
    
    @tournament_stats = gather_tournament_stats
    @current_matches = @tournament.tournament_matches.includes(:home_team, :away_team).where(status: 'in_progress')
    @upcoming_matches = @tournament.tournament_matches.includes(:home_team, :away_team).where(status: 'scheduled').limit(5)
    @recent_updates = gather_recent_updates
    @checklists = @tournament.tournament_checklists.pending.by_priority.limit(5)
    
    respond_to do |format|
      format.html
      format.json { render json: {
        stats: @tournament_stats,
        current_matches: @current_matches,
        upcoming_matches: @upcoming_matches,
        updates: @recent_updates
      }}
    end
  end
  
  # Quick action buttons
  def announce
    announcement = params[:message]
    
    # Send notification to all participants
    @tournament.tournament_teams.approved.each do |team|
      Notification.create!(
        user: team.captain,
        notification_type: "tournament_announcement",
        related_id: @tournament.id,
        related_type: "Tournament",
        content: announcement
      )
    end
    
    # Create live update
    @tournament.tournament_live_updates.create!(
      update_type: 'announcement',
      content: announcement,
      created_by: current_user
    )
    
    redirect_to tournament_dashboard_path(@tournament), 
                notice: '공지사항이 발송되었습니다.'
  end
  
  def pause
    @tournament.update!(status: 'paused', paused_at: Time.current)
    
    # Notify all participants
    send_bulk_notification('tournament_paused', '대회가 일시 중지되었습니다.')
    
    redirect_to tournament_dashboard_path(@tournament), 
                notice: '대회가 일시 중지되었습니다.'
  end
  
  def resume
    @tournament.update!(status: 'ongoing', paused_at: nil)
    
    # Notify all participants
    send_bulk_notification('tournament_resumed', '대회가 재개되었습니다.')
    
    redirect_to tournament_dashboard_path(@tournament), 
                notice: '대회가 재개되었습니다.'
  end
  
  def update_progress
    @tournament.update_progress!
    
    respond_to do |format|
      format.json { render json: { progress: @tournament.progress_percentage } }
    end
  end
  
  # Batch operations
  def batch_approve_teams
    pending_teams = @tournament.tournament_teams.pending
    approved_count = 0
    
    pending_teams.each do |team|
      if team.approve!
        approved_count += 1
        
        # Send approval notification
        Notification.create!(
          user: team.captain,
          notification_type: "team_approved",
          related_id: @tournament.id,
          related_type: "Tournament",
          content: "#{team.team_name} 팀의 참가가 승인되었습니다."
        )
      end
    end
    
    redirect_to tournament_dashboard_path(@tournament), 
                notice: "#{approved_count}개 팀이 승인되었습니다."
  end
  
  def batch_send_reminders
    @tournament.tournament_teams.approved.each do |team|
      TournamentReminderJob.perform_later(team)
    end
    
    redirect_to tournament_dashboard_path(@tournament), 
                notice: '리마인더가 발송되었습니다.'
  end
  
  def generate_report
    # Generate tournament report
    report = TournamentReportService.new(@tournament).generate
    
    respond_to do |format|
      format.pdf do
        send_data report.to_pdf,
                  filename: "tournament_report_#{@tournament.id}.pdf",
                  type: 'application/pdf'
      end
      format.json { render json: report.to_json }
    end
  end
  
  private
  
  def set_tournament
    @tournament = Tournament.find(params[:tournament_id] || params[:id])
  end
  
  def check_organizer_permission
    unless @tournament.organizer == current_user || current_user.admin?
      redirect_to tournaments_path, alert: '권한이 없습니다.'
    end
  end
  
  def gather_tournament_stats
    Rails.cache.fetch("tournament_stats_#{@tournament.id}", expires_in: 1.minute) do
      {
        progress: @tournament.progress_percentage,
        total_teams: @tournament.tournament_teams.count,
        approved_teams: @tournament.tournament_teams.approved.count,
        checked_in_teams: @tournament.tournament_teams.where(checked_in: true).count,
        total_matches: @tournament.tournament_matches.count,
        completed_matches: @tournament.tournament_matches.where.not(winner_id: nil).count,
        current_round: @tournament.current_round || 'N/A',
        status: @tournament.status
      }
    end
  end
  
  def gather_recent_updates
    updates = []
    
    # Recent check-ins
    recent_checkins = @tournament.tournament_teams
                                 .where.not(checked_in_at: nil)
                                 .where('checked_in_at > ?', 30.minutes.ago)
                                 .order(checked_in_at: :desc)
                                 .limit(5)
    
    recent_checkins.each do |team|
      updates << {
        type: 'check_in',
        message: "#{team.team_name} 체크인 완료",
        time: team.checked_in_at
      }
    end
    
    # Recent match results
    recent_matches = @tournament.tournament_matches
                               .where.not(winner_id: nil)
                               .where('updated_at > ?', 30.minutes.ago)
                               .order(updated_at: :desc)
                               .limit(5)
    
    recent_matches.each do |match|
      updates << {
        type: 'match_result',
        message: "#{match.home_team.team_name} vs #{match.away_team.team_name} 경기 종료",
        time: match.updated_at
      }
    end
    
    updates.sort_by { |u| u[:time] }.reverse.first(10)
  end
  
  def send_bulk_notification(type, message)
    @tournament.tournament_teams.approved.each do |team|
      Notification.create!(
        user: team.captain,
        notification_type: type,
        related_id: @tournament.id,
        related_type: "Tournament",
        content: message
      )
    end
  end
end