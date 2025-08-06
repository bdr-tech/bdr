class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  include Cacheable

  before_action :current_user

  # 전역 에러 핸들링
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  # 권한 관련 에러
  class NotAuthorizedError < StandardError; end
  rescue_from NotAuthorizedError, with: :forbidden

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "로그인이 필요합니다."
      redirect_to login_path
      return false
    end
    true
  end

  def require_admin
    return unless require_login

    unless current_user&.admin?
      flash[:alert] = "관리자 권한이 필요합니다."
      redirect_to root_path
      return false
    end
    true
  end

  def log_admin_action(action, resource_type, resource_id = nil, details = nil)
    if current_user&.admin?
      AdminLog.log_action(current_user, action, resource_type, resource_id, details, request)
    end
  end

  helper_method :current_user, :logged_in?
  
  # Alias for compatibility with some controllers
  alias_method :authenticate_user!, :require_login

  # 에러 핸들러
  def record_not_found
    respond_to do |format|
      format.html { render "errors/404", status: :not_found }
      format.json { render json: { error: "요청하신 리소스를 찾을 수 없습니다." }, status: :not_found }
    end
  end

  def bad_request
    respond_to do |format|
      format.html { render "errors/400", status: :bad_request }
      format.json { render json: { error: "잘못된 요청입니다." }, status: :bad_request }
    end
  end

  def unprocessable_entity(exception)
    respond_to do |format|
      format.html {
        flash[:alert] = exception.record.errors.full_messages.join(", ")
        redirect_back(fallback_location: root_path)
      }
      format.json { render json: { errors: exception.record.errors }, status: :unprocessable_entity }
    end
  end

  def forbidden
    respond_to do |format|
      format.html { render "errors/403", status: :forbidden }
      format.json { render json: { error: "권한이 없습니다." }, status: :forbidden }
    end
  end

  # 로깅
  def log_error(exception)
    Rails.logger.error "ERROR: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if Rails.env.development?
  end
end
