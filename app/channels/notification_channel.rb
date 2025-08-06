class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # Stream for the current user's notifications
    stream_for current_user

    # Send initial unread count
    transmit({
      type: "unread_count",
      count: current_user.notifications.unread_only.count
    })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  def mark_as_read(data)
    notification = current_user.notifications.find_by(id: data["notification_id"])

    if notification
      notification.mark_as_read!

      # Broadcast updated unread count to user
      transmit({
        type: "unread_count",
        count: current_user.notifications.unread_only.count
      })
    end
  end

  def mark_all_as_read
    current_user.notifications.unread_only.update_all(status: "read", read_at: Time.current)

    # Broadcast updated unread count to user
    transmit({
      type: "unread_count",
      count: 0
    })
  end
end
