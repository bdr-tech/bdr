module NotificationAdapter
  extend ActiveSupport::Concern
  
  # Adapter for compatibility between old and new notification systems
  def self.create_notification(user:, type:, content:, related_object: nil)
    if related_object
      # Use polymorphic association
      Notification.create!(
        user: user,
        notification_type: type,
        content: content,
        notifiable: related_object
      )
    else
      # Create without association
      Notification.create!(
        user: user,
        notification_type: type,
        content: content
      )
    end
  end
  
  # Helper method for tournament notifications
  def self.create_tournament_notification(user:, tournament:, type:, content:)
    create_notification(
      user: user,
      type: type,
      content: content,
      related_object: tournament
    )
  end
end