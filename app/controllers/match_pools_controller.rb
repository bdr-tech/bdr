class MatchPoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match_pool, only: [ :show, :join, :leave ]

  def index
    @match_pools = MatchPool.includes(:match_pool_participants)
                           .where(status: "forming")
                           .where("match_time > ?", Time.current)
                           .order(match_time: :asc)

    # 필터링
    if params[:city].present?
      @match_pools = @match_pools.where(city: params[:city])
    end

    if params[:skill_level].present?
      level = params[:skill_level].to_i
      @match_pools = @match_pools.where(skill_level: (level - 1)..(level + 1))
    end

    if params[:date].present?
      date = Date.parse(params[:date])
      @match_pools = @match_pools.where(match_time: date.beginning_of_day..date.end_of_day)
    end
  end

  def show
    @participants = @match_pool.match_pool_participants.includes(:user)
    @is_participant = @participants.exists?(user: current_user)
  end

  def join
    if @match_pool.current_players >= @match_pool.max_players
      redirect_to @match_pool, alert: "이미 정원이 가득 찼습니다."
      return
    end

    if @match_pool.match_pool_participants.exists?(user: current_user)
      redirect_to @match_pool, alert: "이미 참가 중입니다."
      return
    end

    ActiveRecord::Base.transaction do
      @match_pool.match_pool_participants.create!(
        user: current_user,
        status: "waiting"
      )

      @match_pool.increment!(:current_players)

      player_ids = @match_pool.player_ids || []
      player_ids << current_user.id
      @match_pool.update!(player_ids: player_ids.uniq)
    end

    redirect_to @match_pool, notice: "매치 풀에 참가했습니다."
  end

  def leave
    participant = @match_pool.match_pool_participants.find_by(user: current_user)

    unless participant
      redirect_to @match_pool, alert: "참가 중이 아닙니다."
      return
    end

    ActiveRecord::Base.transaction do
      participant.destroy
      @match_pool.decrement!(:current_players)

      player_ids = @match_pool.player_ids || []
      player_ids.delete(current_user.id)
      @match_pool.update!(player_ids: player_ids)
    end

    redirect_to match_pools_path, notice: "매치 풀에서 나왔습니다."
  end

  private

  def set_match_pool
    @match_pool = MatchPool.find(params[:id])
  end
end
