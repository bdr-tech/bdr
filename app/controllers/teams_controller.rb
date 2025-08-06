class TeamsController < ApplicationController
  before_action :require_login
  before_action :require_premium, only: [:new, :create]
  before_action :set_team, only: [:show, :edit, :update, :destroy, :add_member, :remove_member, :search_users]
  before_action :authorize_captain, only: [:edit, :update, :destroy, :add_member, :remove_member]
  
  def index
    @my_teams = current_user.teams.includes(:captain, :users)
    @captained_teams = current_user.captained_teams.includes(:users)
  end
  
  def show
    @members = @team.team_members.includes(:user)
  end
  
  def new
    @team = Team.new
  end
  
  def create
    @team = current_user.captained_teams.build(team_params)
    
    if @team.save
      # 주장을 팀 멤버로 추가
      @team.add_member(current_user, 'captain')
      redirect_to @team, notice: '팀이 성공적으로 생성되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @team.update(team_params)
      redirect_to @team, notice: '팀 정보가 업데이트되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @team.destroy
    redirect_to teams_path, notice: '팀이 삭제되었습니다.'
  end
  
  def search_users
    query = params[:q]
    @users = User.where("name LIKE ? OR nickname LIKE ? OR email LIKE ?", 
                        "%#{query}%", "%#{query}%", "%#{query}%")
                 .where.not(id: @team.users.pluck(:id))
                 .limit(10)
    
    render json: @users.map { |u| 
      { 
        id: u.id, 
        name: u.name, 
        nickname: u.nickname,
        email: u.email,
        positions: u.positions
      } 
    }
  end
  
  def add_member
    user = User.find(params[:user_id])
    
    if @team.add_member(user, params[:role] || 'player')
      render json: { success: true, message: '멤버가 추가되었습니다.' }
    else
      render json: { success: false, message: '멤버 추가에 실패했습니다.' }, status: :unprocessable_entity
    end
  end
  
  def remove_member
    user = User.find(params[:user_id])
    
    if user == @team.captain
      render json: { success: false, message: '주장은 제거할 수 없습니다.' }, status: :unprocessable_entity
    elsif @team.remove_member(user)
      render json: { success: true, message: '멤버가 제거되었습니다.' }
    else
      render json: { success: false, message: '멤버 제거에 실패했습니다.' }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_team
    @team = Team.find(params[:id])
  end
  
  def authorize_captain
    unless @team.captain == current_user
      redirect_to teams_path, alert: '권한이 없습니다.'
    end
  end
  
  def require_premium
    unless current_user&.premium?
      redirect_to teams_path, alert: '팀 등록은 프리미엄 회원만 가능합니다.'
    end
  end
  
  def team_params
    params.require(:team).permit(:name, :description, :logo_url, :home_court, :city, :district)
  end
end