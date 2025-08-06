class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  # 알림 타입
  NOTIFICATION_TYPES = {
    # 경기 관련
    "game_application_received" => "새로운 경기 참가 신청",
    "game_application_approved" => "경기 참가 승인",
    "game_application_rejected" => "경기 참가 거절",
    "game_payment_confirmed" => "입금 확인 완료",
    "game_payment_requested" => "입금 요청",
    "game_reminder" => "경기 리마인더",
    "game_cancelled" => "경기 취소",
    "game_updated" => "경기 정보 변경",
    "game_completed" => "경기 완료",
    "game_closed" => "경기 마감",
    "partial_settlement" => "부분 정산",

    # 평가 관련
    "evaluation_reminder" => "평가 요청",
    "evaluation_closed" => "평가 기간 종료",
    "evaluation_summary" => "평가 결과 요약",
    "evaluation_received" => "새로운 평가 받음",
    "rating_updated" => "평점 업데이트",

    # 시스템 알림
    "welcome" => "환영 메시지",
    "profile_incomplete" => "프로필 완성 요청",
    "achievement_unlocked" => "업적 달성",
    "system_announcement" => "시스템 공지사항"
  }.freeze

  # 상태
  enum :status, {
    unread: 0,
    read: 1,
    archived: 2
  }

  # 우선순위
  enum :priority, {
    low: 0,
    normal: 1,
    high: 2,
    urgent: 3
  }

  # 스코프
  scope :recent, -> { order(created_at: :desc) }
  scope :unread_only, -> { where(status: "unread") }
  scope :high_priority, -> { where(priority: [ "high", "urgent" ]) }
  scope :for_display, -> { recent.limit(10) }

  # 검증
  validates :user, presence: true
  validates :notification_type, presence: true, inclusion: { in: NOTIFICATION_TYPES.keys }
  validates :title, presence: true
  validates :message, presence: true

  # 콜백
  after_create :send_realtime_notification
  after_create :send_email_if_enabled

  # 클래스 메서드
  class << self
    def create_for_user(user, type, options = {})
      return unless user && NOTIFICATION_TYPES.key?(type.to_s)

      create!(
        user: user,
        notification_type: type,
        title: options[:title] || NOTIFICATION_TYPES[type.to_s],
        message: options[:message] || "",
        data: options[:data] || {},
        notifiable: options[:notifiable],
        priority: options[:priority] || "normal"
      )
    end

    def create_for_users(users, type, options = {})
      users.each do |user|
        create_for_user(user, type, options)
      end
    end
  end

  # 인스턴스 메서드
  def mark_as_read!
    update!(status: "read", read_at: Time.current) if unread?
  end

  def mark_as_unread!
    update!(status: "unread", read_at: nil)
  end

  def archive!
    update!(status: "archived")
  end

  def action_url
    case notification_type
    when "game_application_received", "game_application_approved", "game_application_rejected"
      Rails.application.routes.url_helpers.game_path(notifiable) if notifiable.is_a?(Game)
    when "game_payment_confirmed", "game_payment_requested", "game_reminder", "game_cancelled", "game_updated", "game_completed"
      Rails.application.routes.url_helpers.game_path(notifiable) if notifiable.is_a?(Game)
    when "evaluation_reminder", "evaluation_closed", "evaluation_summary"
      if data && data["game_id"]
        game = Game.find_by(id: data["game_id"])
        Rails.application.routes.url_helpers.game_player_evaluations_path(game) if game
      end
    when "evaluation_received"
      Rails.application.routes.url_helpers.profile_path
    when "profile_incomplete"
      Rails.application.routes.url_helpers.edit_profile_path
    else
      nil
    end
  end

  def icon
    case notification_type
    when /game_/
      "🏀"
    when /evaluation_/
      "🌟"
    when "welcome"
      "👋"
    when "profile_incomplete"
      "📝"
    when "achievement_unlocked"
      "🏆"
    when "system_announcement"
      "📢"
    else
      "🔔"
    end
  end

  def color_class
    case priority
    when "urgent"
      "text-red-600 bg-red-50"
    when "high"
      "text-orange-600 bg-orange-50"
    when "low"
      "text-gray-600 bg-gray-50"
    else
      "text-blue-600 bg-blue-50"
    end
  end

  private

  # Clear user's notification count cache when notification is created/updated
  after_commit :clear_user_cache, on: [ :create, :update ]

  def clear_user_cache
    Rails.cache.delete([ "user", user_id, "unread_notifications_count" ])
  end

  def send_realtime_notification
    # ActionCable을 통한 실시간 알림 전송
    NotificationChannel.broadcast_to(
      user,
      {
        id: id,
        type: notification_type,
        title: title,
        message: message,
        icon: icon,
        url: action_url,
        created_at: created_at.strftime("%Y-%m-%d %H:%M")
      }
    )
  rescue => e
    Rails.logger.error "Failed to send realtime notification: #{e.message}"
  end

  def send_email_if_enabled
    # 이메일 알림 설정이 켜져있고, 중요도가 높은 경우 이메일 전송
    if user.email_notifications? && priority.in?([ "high", "urgent" ])
      NotificationMailer.notify(self).deliver_later
    end
  rescue => e
    Rails.logger.error "Failed to send email notification: #{e.message}"
  end
end
