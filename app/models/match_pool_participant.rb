class MatchPoolParticipant < ApplicationRecord
  belongs_to :match_pool
  belongs_to :user

  # Validations
  validates :user_id, uniqueness: { scope: :match_pool_id, message: "는 이미 이 매치 풀에 참가 중입니다" }
  validates :status, inclusion: { in: %w[waiting confirmed declined] }

  # Scopes
  scope :waiting, -> { where(status: "waiting") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :declined, -> { where(status: "declined") }

  # Callbacks
  after_create :increment_pool_counter
  after_destroy :decrement_pool_counter

  def confirm!
    update!(status: "confirmed", confirmed_at: Time.current)
  end

  def decline!
    update!(status: "declined")
  end

  private

  def increment_pool_counter
    match_pool.increment!(:current_players)
  end

  def decrement_pool_counter
    match_pool.decrement!(:current_players)
  end
end
