class TournamentLiveUpdate < ApplicationRecord
  belongs_to :tournament
  belongs_to :tournament_match, optional: true
  belongs_to :user

  UPDATE_TYPES = %w[
    score_update
    match_start
    match_end
    quarter_end
    timeout
    announcement
    highlight
    injury
    substitution
  ].freeze

  validates :update_type, inclusion: { in: UPDATE_TYPES }

  scope :official, -> { where(is_official: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_match, ->(match) { where(tournament_match: match) }

  after_create_commit :broadcast_update

  def score_update?
    update_type == "score_update"
  end

  def match_event?
    %w[match_start match_end quarter_end].include?(update_type)
  end

  private

  def broadcast_update
    # ActionCable로 실시간 업데이트 전송
    TournamentChannel.broadcast_to(
      tournament,
      {
        type: update_type,
        data: data,
        match_id: tournament_match_id,
        created_at: created_at,
        user: {
          id: user.id,
          name: user.name,
          nickname: user.nickname
        }
      }
    )
  end
end
