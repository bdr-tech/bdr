class TournamentCheckInsController < ApplicationController
  before_action :authenticate_user!, except: [:scan]
  before_action :set_tournament
  before_action :check_organizer_permission, except: [:scan, :show]
  
  def index
    @teams = @tournament.tournament_teams.approved
    @checked_in_teams = @teams.where(checked_in: true)
    @pending_teams = @teams.where(checked_in: false)
    
    @check_in_stats = {
      total: @teams.count,
      checked_in: @checked_in_teams.count,
      pending: @pending_teams.count,
      percentage: @teams.count > 0 ? (@checked_in_teams.count.to_f / @teams.count * 100).round : 0
    }
  end
  
  def show
    @team = @tournament.tournament_teams.find(params[:id])
    
    respond_to do |format|
      format.html
      format.json { 
        response_data = {
          team: @team,
          checked_in: @team.checked_in?
        }
        response_data[:qr_code] = @team.qr_code if Rails.application.config.qrcode_enabled
        render json: response_data
      }
    end
  end
  
  # QR code scan endpoint
  def scan
    @team = TournamentTeam.find_by(qr_token: params[:qr_token])
    
    if @team.nil?
      render json: { error: '유효하지 않은 QR 코드입니다.' }, status: :not_found
    elsif @team.checked_in?
      render json: { 
        status: 'already_checked_in',
        team: @team.team_name,
        checked_in_at: @team.checked_in_at
      }
    else
      @team.check_in!
      
      # Send notification to team captain
      Notification.create!(
        user: @team.captain,
        notification_type: "check_in_confirmed",
        related_id: @team.tournament.id,
        related_type: "Tournament",
        content: "#{@team.team_name} 팀 체크인이 완료되었습니다."
      )
      
      render json: { 
        status: 'success',
        team: @team.team_name,
        checked_in_at: @team.checked_in_at
      }
    end
  end
  
  # Manual check-in
  def check_in
    @team = @tournament.tournament_teams.find(params[:id])
    
    if @team.check_in!
      redirect_to tournament_check_ins_path(@tournament), 
                  notice: "#{@team.team_name} 팀이 체크인되었습니다."
    else
      redirect_to tournament_check_ins_path(@tournament), 
                  alert: '체크인에 실패했습니다.'
    end
  end
  
  # Manual check-out
  def check_out
    @team = @tournament.tournament_teams.find(params[:id])
    
    if @team.check_out!
      redirect_to tournament_check_ins_path(@tournament), 
                  notice: "#{@team.team_name} 팀의 체크인이 취소되었습니다."
    else
      redirect_to tournament_check_ins_path(@tournament), 
                  alert: '체크인 취소에 실패했습니다.'
    end
  end
  
  # Generate QR codes for all teams
  def generate_all_qr
    unless Rails.application.config.qrcode_enabled
      redirect_to tournament_check_ins_path(@tournament), 
                  alert: "QR 코드 기능이 비활성화되어 있습니다."
      return
    end
    
    teams_without_qr = @tournament.tournament_teams.approved.where(qr_token: nil)
    
    teams_without_qr.each do |team|
      team.generate_qr_token!
    end
    
    redirect_to tournament_check_ins_path(@tournament), 
                notice: "#{teams_without_qr.count}개 팀의 QR 코드가 생성되었습니다."
  end
  
  # Download QR codes as PDF
  def download_qr_codes
    @teams = @tournament.tournament_teams.approved
    
    respond_to do |format|
      format.pdf do
        # Generate PDF with QR codes
        # This would require a PDF generation gem like Prawn
        redirect_to tournament_check_ins_path(@tournament), 
                    alert: 'PDF 다운로드 기능은 준비 중입니다.'
      end
    end
  end
  
  private
  
  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def check_organizer_permission
    unless @tournament.organizer == current_user || current_user.admin?
      redirect_to tournaments_path, alert: '권한이 없습니다.'
    end
  end
end