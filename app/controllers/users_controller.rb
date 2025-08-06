class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :edit, :update, :notification_settings, :update_notification_settings ]
  before_action :authorize_user, only: [ :edit, :update, :notification_settings, :update_notification_settings ]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(signup_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to profile_path, notice: "회원가입이 완료되었습니다!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    redirect_to profile_path
  end

  def edit
    redirect_to edit_profile_path
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: "프로필이 성공적으로 업데이트되었습니다."
    else
      render :edit
    end
  end

  def notification_settings
    @notification_preferences = @user.notification_preferences_hash
  end

  def update_notification_settings
    if params[:notification_type].present?
      # AJAX update for individual toggle
      success = @user.update_notification_preference(params[:notification_type], params[:enabled] == "true")

      render json: {
        success: success,
        message: success ? "알림 설정이 업데이트되었습니다." : "알림 설정 업데이트에 실패했습니다."
      }
    else
      # Form submission for all settings
      if @user.update(notification_params)
        redirect_to notification_settings_users_path, notice: "알림 설정이 성공적으로 업데이트되었습니다."
      else
        @notification_preferences = @user.notification_preferences_hash
        render :notification_settings
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    unless @user == current_user || current_user&.admin?
      redirect_to root_path, alert: "권한이 없습니다."
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :nickname, :real_name,
                                  :height, :weight, :city, :district, :team_name,
                                  :bio, :birth_date, :basketball_experience,
                                  :bank_name, :account_number, :account_holder,
                                  positions: [])
  end

  def notification_params
    params.require(:user).permit(:email_notifications, :sms_notifications, :push_notifications)
  end
  
  def signup_params
    params.require(:user).permit(:name, :email, :phone, :nickname, :city, :district)
  end
end
