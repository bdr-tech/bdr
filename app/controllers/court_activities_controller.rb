class CourtActivitiesController < ApplicationController
  before_action :require_login
  before_action :set_court

  def check_in
    activity = @court.court_activities.build(
      user: current_user,
      activity_type: "check_in",
      player_count: params[:player_count] || 1,
      recorded_at: Time.current,
      metadata: {
        location: params[:location],
        device: request.user_agent
      }
    )

    if activity.save
      render json: {
        success: true,
        current_occupancy: @court.current_occupancy,
        occupancy_level: @court.occupancy_level,
        message: "체크인 되었습니다!"
      }
    else
      render json: { success: false, errors: activity.errors.full_messages }
    end
  end

  def check_out
    activity = @court.court_activities.build(
      user: current_user,
      activity_type: "check_out",
      player_count: params[:player_count] || 1,
      recorded_at: Time.current
    )

    if activity.save
      render json: {
        success: true,
        current_occupancy: @court.current_occupancy,
        occupancy_level: @court.occupancy_level,
        message: "체크아웃 되었습니다!"
      }
    else
      render json: { success: false, errors: activity.errors.full_messages }
    end
  end

  def report
    activity = @court.court_activities.build(
      user: current_user,
      activity_type: "game_report",
      player_count: params[:player_count].to_i,
      recorded_at: Time.current,
      metadata: {
        game_type: params[:game_type],
        notes: params[:notes]
      }
    )

    if activity.save
      render json: {
        success: true,
        current_occupancy: @court.current_occupancy,
        occupancy_level: @court.occupancy_level,
        message: "코트 상태가 업데이트되었습니다!"
      }
    else
      render json: { success: false, errors: activity.errors.full_messages }
    end
  end

  private

  def set_court
    @court = Court.find(params[:court_id])
  end
end
