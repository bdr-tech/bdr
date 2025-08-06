class AdminLog < ApplicationRecord
  belongs_to :user

  validates :action, presence: true
  validates :resource_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_resource_type, ->(type) { where(resource_type: type) }
  scope :by_user, ->(user) { where(user: user) }

  def self.log_action(user, action, resource_type, resource_id = nil, details = nil, request = nil)
    create!(
      user: user,
      action: action,
      resource_type: resource_type,
      resource_id: resource_id,
      details: details,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end

  def resource
    return nil unless resource_id && resource_type
    resource_type.constantize.find_by(id: resource_id)
  end
end
