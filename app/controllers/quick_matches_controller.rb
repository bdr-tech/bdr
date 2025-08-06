class QuickMatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quick_match_service

  def new
    @preferences = current_user.quick_match_preference || QuickMatchPreference.new
    @recent_matches = current_user.quick_match_histories.includes(:game, :match_pool).order(created_at: :desc).limit(5)
  end

  def create
    result = @quick_match_service.find_match

    # 퀵매치 기록 생성
    history = current_user.quick_match_histories.create!(
      match_type: result[:type],
      game: result[:game],
      match_pool: result[:match_pool],
      successful: true,
      search_criteria: quick_match_params,
      search_time_seconds: 0
    )

    case result[:type]
    when :instant_match
      # 즉시 매치 - 경기에 자동 신청
      application = GameApplication.create!(
        user: current_user,
        game: result[:game],
        status: "pending",
        message: "퀵매치를 통한 자동 신청입니다."
      )

      redirect_to game_path(result[:game]), notice: "적합한 경기를 찾았습니다! 자동으로 신청되었습니다."
    when :pool_match
      # 풀 매치 - 매치 풀 대기
      redirect_to match_pool_path(result[:match_pool]), notice: "매치 풀에 참가했습니다. 최소 인원이 모이면 경기가 생성됩니다."
    end
  end

  def preferences
    @preferences = current_user.quick_match_preference || current_user.build_quick_match_preference
  end

  def update_preferences
    @preferences = current_user.quick_match_preference || current_user.build_quick_match_preference

    if @preferences.update(preference_params)
      redirect_to quick_matches_path, notice: "퀵매치 선호도가 업데이트되었습니다."
    else
      render :preferences
    end
  end

  def toggle_auto_match
    @quick_match_service.toggle_auto_match(params[:enabled] == "true")

    respond_to do |format|
      format.json { render json: { success: true, enabled: params[:enabled] == "true" } }
      format.html { redirect_back(fallback_location: quick_matches_path) }
    end
  end

  private

  def set_quick_match_service
    @quick_match_service = QuickMatchService.new(current_user)
  end

  def quick_match_params
    params.permit(:match_time, :location, :skill_level, :game_type)
  end

  def preference_params
    params.require(:quick_match_preference).permit(
      :preferred_level_range,
      :max_distance_km,
      :auto_match_enabled,
      :min_players,
      :max_players,
      preferred_times: {},
      preferred_locations: [],
      preferred_game_types: []
    )
  end
end
