class OutdoorCourtsController < ApplicationController
  before_action :require_login
  before_action :set_outdoor_court, only: [ :show, :edit, :update, :destroy ]

  def index
    @outdoor_courts = OutdoorCourt.recent.includes(:user)

    if params[:lat] && params[:lng]
      @outdoor_courts = @outdoor_courts.nearby(params[:lat].to_f, params[:lng].to_f, 10)
      @user_location = { lat: params[:lat].to_f, lng: params[:lng].to_f }
    end

    @outdoor_courts = @outdoor_courts.limit(20)
  end

  def show
    @distance = @outdoor_court.distance_from(params[:lat].to_f, params[:lng].to_f) if params[:lat] && params[:lng]
  end

  def new
    @outdoor_court = OutdoorCourt.new
  end

  def create
    @outdoor_court = OutdoorCourt.new(outdoor_court_params)
    @outdoor_court.user = current_user

    if @outdoor_court.save
      redirect_to @outdoor_court, notice: "🏀 실외 코트가 성공적으로 등록되었습니다!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless @outdoor_court.user == current_user
      redirect_to @outdoor_court, alert: "자신이 등록한 코트만 수정할 수 있습니다."
      nil
    end
  end

  def update
    unless @outdoor_court.user == current_user
      redirect_to @outdoor_court, alert: "자신이 등록한 코트만 수정할 수 있습니다."
      return
    end

    if @outdoor_court.update(outdoor_court_params)
      redirect_to @outdoor_court, notice: "코트 정보가 성공적으로 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless @outdoor_court.user == current_user
      redirect_to outdoor_courts_path, alert: "자신이 등록한 코트만 삭제할 수 있습니다."
      return
    end

    @outdoor_court.destroy
    redirect_to outdoor_courts_path, notice: "코트가 삭제되었습니다."
  end

  def nearby
    if params[:lat] && params[:lng]
      @outdoor_courts = OutdoorCourt.nearby(params[:lat].to_f, params[:lng].to_f, 10)
                                   .includes(:user)
                                   .limit(20)
      @user_location = { lat: params[:lat].to_f, lng: params[:lng].to_f }
    else
      @outdoor_courts = OutdoorCourt.recent.includes(:user).limit(20)
    end

    render :index
  end

  private

  def set_outdoor_court
    @outdoor_court = OutdoorCourt.find(params[:id])
  end

  def outdoor_court_params
    params.require(:outdoor_court).permit(:title, :image1, :image2, :latitude, :longitude, :address)
  end
end
