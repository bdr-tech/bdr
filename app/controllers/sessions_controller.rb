class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      session[:user_id] = user.id
      # Set encrypted cookie for ActionCable authentication
      cookies.encrypted[:user_id] = user.id
      redirect_to profile_path, notice: "로그인 되었습니다."
    else
      flash.now[:alert] = "이메일을 확인해주세요."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    # Clear encrypted cookie for ActionCable
    cookies.delete(:user_id)
    redirect_to root_path, notice: "로그아웃 되었습니다."
  end
end
