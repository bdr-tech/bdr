class NotificationsController < ApplicationController
  before_action :require_login
  before_action :set_notification, only: [ :show, :mark_as_read, :mark_as_unread, :destroy ]

  def index
    @notifications = current_user.notifications
                                .includes(:notifiable)
                                .recent
                                .page(params[:page])
                                .per(20)

    # 필터링
    if params[:status].present?
      @notifications = @notifications.where(status: params[:status])
    end

    if params[:type].present?
      @notifications = @notifications.where(notification_type: params[:type])
    end

    respond_to do |format|
      format.html
      format.json { render json: @notifications }
    end
  end

  def show
    @notification.mark_as_read!

    if @notification.action_url
      redirect_to @notification.action_url
    else
      redirect_to notifications_path
    end
  end

  def unread_count
    count = current_user.cached_unread_notifications_count
    render json: { count: count }
  end

  def mark_as_read
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { status: "read" } }
    end
  end

  def mark_as_unread
    @notification.mark_as_unread!

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { status: "unread" } }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(
      status: "read",
      read_at: Time.current
    )

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: "모든 알림을 읽음으로 표시했습니다.") }
      format.json { render json: { message: "All notifications marked as read" } }
    end
  end

  def destroy
    @notification.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: "알림이 삭제되었습니다.") }
      format.json { head :no_content }
    end
  end

  def destroy_all_read
    current_user.notifications.read.destroy_all

    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: "읽은 알림이 모두 삭제되었습니다.") }
      format.json { head :no_content }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
