class TournamentTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tournament_template, only: [:show, :use, :duplicate]
  
  def index
    @public_templates = TournamentTemplate.public_templates.popular.limit(10)
    @my_templates = current_user.tournament_templates if current_user
    @preset_templates = generate_preset_templates
  end
  
  def show
    respond_to do |format|
      format.html
      format.json { render json: @tournament_template }
    end
  end
  
  def create
    @tournament_template = current_user.tournament_templates.build(tournament_template_params)
    
    if @tournament_template.save
      redirect_to tournament_templates_path, notice: '템플릿이 저장되었습니다.'
    else
      redirect_to tournament_templates_path, alert: '템플릿 저장에 실패했습니다.'
    end
  end
  
  def use
    @tournament = @tournament_template.create_tournament(
      organizer: current_user,
      tournament_start_at: params[:start_date],
      tournament_end_at: params[:end_date]
    )
    
    if @tournament.persisted?
      @tournament_template.increment_usage!
      redirect_to edit_tournament_path(@tournament), notice: '템플릿을 사용하여 대회가 생성되었습니다.'
    else
      redirect_to tournament_templates_path, alert: '대회 생성에 실패했습니다.'
    end
  end
  
  def duplicate
    new_template = @tournament_template.dup
    new_template.creator = current_user
    new_template.name = "#{@tournament_template.name} (복사본)"
    new_template.is_public = false
    new_template.usage_count = 0
    
    if new_template.save
      redirect_to tournament_templates_path, notice: '템플릿이 복사되었습니다.'
    else
      redirect_to tournament_templates_path, alert: '템플릿 복사에 실패했습니다.'
    end
  end
  
  private
  
  def set_tournament_template
    @tournament_template = TournamentTemplate.find(params[:id])
  end
  
  def tournament_template_params
    params.require(:tournament_template).permit(
      :name, :description, :preset_type, :category, :is_public,
      settings: {}
    )
  end
  
  def generate_preset_templates
    TournamentTemplate::PRESET_TYPES.first(3).map do |type|
      TournamentTemplate.new(
        name: type.humanize,
        preset_type: type,
        settings: TournamentTemplate.default_settings_for(type),
        is_public: true
      )
    end
  end
end