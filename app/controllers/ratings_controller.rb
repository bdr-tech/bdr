class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_game
  before_action :check_game_ended
  before_action :check_participation
  before_action :check_not_already_rated, only: [ :new, :create ]

  def index
    @ratings = @game.ratings.includes(:user, :rated_user)
    @my_ratings = @ratings.where(user: current_user)
    @received_ratings = @ratings.where(rated_user: current_user)
  end

  def new
    @participants = @game.all_participants.where.not(id: current_user.id)
    @host = @game.organizer unless @game.organizer == current_user
    @existing_ratings = current_user.ratings.where(game: @game).pluck(:rated_user_id)
  end

  def create
    success_count = 0
    error_messages = []

    rating_params[:ratings].each do |user_id, rating_data|
      next if rating_data[:rating].blank?

      rated_user = User.find(user_id)
      rating_type = rated_user == @game.organizer ? "host" : "player"

      rating = current_user.ratings.build(
        game: @game,
        rated_user: rated_user,
        rating: rating_data[:rating],
        rating_type: rating_type,
        comment: rating_data[:comment]
      )

      if rating.save
        success_count += 1
        update_user_rating_stats(rated_user)
      else
        error_messages << "#{rated_user.display_name}: #{rating.errors.full_messages.join(', ')}"
      end
    end

    if success_count > 0
      # 평가 완료 포인트 지급
      current_user.add_points(10, "경기 평가 완료")

      if error_messages.any?
        flash[:warning] = "#{success_count}명 평가 완료. 일부 오류: #{error_messages.join('; ')}"
      else
        flash[:success] = "평가가 완료되었습니다. (+10 포인트)"
      end
    else
      flash[:error] = "평가에 실패했습니다: #{error_messages.join('; ')}"
    end

    redirect_to game_path(@game)
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def check_game_ended
    unless @game.status == "completed"
      flash[:error] = "경기가 종료된 후에만 평가할 수 있습니다."
      redirect_to game_path(@game)
    end
  end

  def check_participation
    unless @game.all_participants.include?(current_user)
      flash[:error] = "경기에 참여한 사용자만 평가할 수 있습니다."
      redirect_to game_path(@game)
    end
  end

  def check_not_already_rated
    if current_user.ratings.where(game: @game).exists?
      flash[:warning] = "이미 평가를 완료했습니다."
      redirect_to game_path(@game)
    end
  end

  def rating_params
    params.permit(rating: {}).to_h
  end

  def update_user_rating_stats(user)
    # 사용자의 평균 평점 업데이트
    ratings = Rating.where(rated_user: user)
    user.update(
      average_rating: ratings.average(:rating) || 2.5,
      rating_count: ratings.count
    )
  end
end
