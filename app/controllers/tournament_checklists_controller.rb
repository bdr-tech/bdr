class TournamentChecklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament
  before_action :check_organizer_permission
  before_action :set_checklist, only: [:complete, :uncomplete, :destroy]
  
  def index
    @checklists_by_phase = {
      'day_before' => @tournament.tournament_checklists.by_phase('day_before').by_priority,
      'game_day' => @tournament.tournament_checklists.by_phase('game_day').by_priority,
      'post_game' => @tournament.tournament_checklists.by_phase('post_game').by_priority
    }
    
    @completion_stats = calculate_completion_stats
  end
  
  def create
    @checklist = @tournament.tournament_checklists.build(checklist_params)
    
    if @checklist.save
      redirect_to tournament_checklists_path(@tournament), notice: '체크리스트 항목이 추가되었습니다.'
    else
      redirect_to tournament_checklists_path(@tournament), alert: '체크리스트 추가에 실패했습니다.'
    end
  end
  
  def complete
    @checklist.complete!
    
    # Execute automated tasks if needed
    if @checklist.automated?
      AutomatedTaskJob.perform_later(@checklist)
    end
    
    respond_to do |format|
      format.html { redirect_to tournament_checklists_path(@tournament) }
      format.json { render json: { status: 'completed', completed_at: @checklist.completed_at } }
    end
  end
  
  def uncomplete
    @checklist.uncomplete!
    
    respond_to do |format|
      format.html { redirect_to tournament_checklists_path(@tournament) }
      format.json { render json: { status: 'pending' } }
    end
  end
  
  def destroy
    @checklist.destroy
    redirect_to tournament_checklists_path(@tournament), notice: '체크리스트 항목이 삭제되었습니다.'
  end
  
  # Execute all automated tasks for a phase
  def execute_automated
    phase = params[:phase]
    checklists = @tournament.tournament_checklists.by_phase(phase).automated.pending
    
    checklists.each do |checklist|
      checklist.execute_automated_task
    end
    
    redirect_to tournament_checklists_path(@tournament), 
                notice: "#{phase} 단계의 자동화 작업이 실행되었습니다."
  end
  
  private
  
  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end
  
  def set_checklist
    @checklist = @tournament.tournament_checklists.find(params[:id])
  end
  
  def check_organizer_permission
    unless @tournament.organizer == current_user || current_user.admin?
      redirect_to tournaments_path, alert: '권한이 없습니다.'
    end
  end
  
  def checklist_params
    params.require(:tournament_checklist).permit(
      :phase, :task_name, :description, :priority, :automated
    )
  end
  
  def calculate_completion_stats
    total = @tournament.tournament_checklists.count
    completed = @tournament.tournament_checklists.completed.count
    
    {
      total: total,
      completed: completed,
      percentage: total > 0 ? (completed.to_f / total * 100).round : 0
    }
  end
end