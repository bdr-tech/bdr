class TournamentRegistrationsController < ApplicationController
  before_action :require_login
  before_action :set_tournament
  before_action :check_registration_open
  
  def new
    @tournament_team = @tournament.tournament_teams.build(captain: current_user)
    @user_teams = current_user.captained_teams.active.includes(:users)
  end
  
  def create
    @tournament_team = @tournament.tournament_teams.build(tournament_team_params)
    @tournament_team.captain = current_user
    
    if @tournament_team.save
      # 기존 팀 연결 시 팀 멤버 자동 추가
      if params[:use_existing_team] == 'true' && params[:team_id].present?
        import_team_members(params[:team_id])
      end
      
      # 선택된 플레이어 추가
      if params[:player_ids].present?
        add_selected_players(params[:player_ids])
      end
      
      redirect_to tournament_path(@tournament), notice: '팀 등록이 완료되었습니다.'
    else
      @user_teams = current_user.captained_teams.active.includes(:users)
      render :new, status: :unprocessable_entity
    end
  end
  
  def load_team_members
    team = Team.find(params[:team_id])
    
    if team.captain == current_user
      members = team.roster
      render json: { success: true, members: members }
    else
      render json: { success: false, message: '권한이 없습니다.' }, status: :forbidden
    end
  end
  
  def search_players
    query = params[:q]
    exclude_ids = params[:exclude_ids] || []
    
    users = User.where("name LIKE ? OR nickname LIKE ? OR email LIKE ?", 
                       "%#{query}%", "%#{query}%", "%#{query}%")
                .where.not(id: exclude_ids)
                .limit(10)
    
    render json: users.map { |u| 
      {
        id: u.id,
        name: u.name,
        nickname: u.nickname,
        email: u.email,
        positions: u.positions,
        skill_level: u.evaluation_rating || 50
      }
    }
  end
  
  private
  
  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def check_registration_open
    unless @tournament.registration_open?
      redirect_to tournament_path(@tournament), alert: '현재 등록 기간이 아닙니다.'
    end
  end
  
  def tournament_team_params
    params.require(:tournament_team).permit(:team_name, :contact_phone, :contact_email, :team_id)
  end
  
  def import_team_members(team_id)
    team = Team.find(team_id)
    @tournament_team.update(team: team, team_name: team.name)
    
    team.team_members.active.each do |member|
      @tournament_team.tournament_players.create(
        user: member.user,
        position: member.user.positions&.first,
        jersey_number: member.jersey_number
      )
    end
  end
  
  def add_selected_players(player_ids)
    player_ids.each do |user_id|
      user = User.find(user_id)
      @tournament_team.tournament_players.create(
        user: user,
        position: user.positions&.first
      )
    end
  end
end