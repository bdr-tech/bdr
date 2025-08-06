class PlayerEvaluationsController < ApplicationController
  before_action :require_login
  before_action :set_game
  before_action :check_evaluation_permission
  before_action :check_evaluation_deadline, only: [ :new, :create ]

  def index
    @evaluations_given = current_user.given_evaluations.for_game(@game)
    @participants = @game.evaluatable_players_for(current_user)
    @evaluation_deadline = @game.evaluation_deadline
  end

  def new
    @evaluated_user = User.find(params[:user_id])

    # 이미 평가했는지 확인
    if current_user.evaluated_user_in_game?(@evaluated_user, @game)
      redirect_to game_player_evaluations_path(@game), alert: "이미 평가를 완료했습니다."
      return
    end

    @evaluation = @game.player_evaluations.build(
      evaluator: current_user,
      evaluated_user: @evaluated_user
    )
  end

  def create
    @evaluation = @game.player_evaluations.build(evaluation_params)
    @evaluation.evaluator = current_user
    @evaluation.evaluated_at = Time.current

    if @evaluation.save
      # 평가 완료 알림 생성
      create_evaluation_notification(@evaluation)

      redirect_to game_player_evaluations_path(@game), notice: "평가가 완료되었습니다."
    else
      @evaluated_user = @evaluation.evaluated_user
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find_by!(game_id: params[:game_id])
  end

  def check_evaluation_permission
    unless @game.all_participants.include?(current_user)
      redirect_to @game, alert: "이 경기에 참가하지 않은 사용자는 평가할 수 없습니다."
    end
  end

  def check_evaluation_deadline
    unless @game.evaluation_available?
      redirect_to @game, alert: "평가 기간이 아닙니다."
    end
  end

  def evaluation_params
    params.require(:player_evaluation).permit(
      :evaluated_user_id, :skill_level, :teamwork, :manner, :memorable, :comment
    )
  end

  def create_evaluation_notification(evaluation)
    Notification.create!(
      user: evaluation.evaluated_user,
      title: "새로운 평가가 도착했습니다! 🌟",
      message: "#{@game.title} 경기에서 함께 플레이한 동료가 평가를 남겼습니다.",
      notification_type: "evaluation_received",
      data: {
        game_id: @game.id,
        game_title: @game.title,
        average_score: evaluation.average_score
      }
    )
  end
end
