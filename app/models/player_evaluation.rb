class PlayerEvaluation < ApplicationRecord
  belongs_to :game
  belongs_to :evaluator, polymorphic: true
  belongs_to :evaluated_user, class_name: "User"

  # Validations
  validates :skill_level, inclusion: { in: 1..5 }, allow_nil: true
  validates :teamwork, inclusion: { in: 1..5 }, allow_nil: true
  validates :manner, inclusion: { in: 1..5 }, allow_nil: true
  validates :comment, length: { maximum: 500 }

  # 한 경기에서 같은 평가자가 같은 사람을 중복 평가할 수 없음
  validates :evaluated_user_id, uniqueness: {
    scope: [ :game_id, :evaluator_id, :evaluator_type ],
    message: "이미 평가를 완료했습니다."
  }

  # Scopes
  scope :memorable, -> { where(memorable: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_game, ->(game) { where(game: game) }
  scope :by_evaluator, ->(evaluator) { where(evaluator: evaluator) }
  scope :for_user, ->(user) { where(evaluated_user: user) }
  scope :completed, -> { where.not(skill_level: nil).where.not(teamwork: nil).where.not(manner: nil) }

  # 평균 점수 계산
  def average_score
    scores = [ skill_level, teamwork, manner ].compact
    return nil if scores.empty?
    (scores.sum.to_f / scores.length).round(1)
  end

  # 평가 완료 여부
  def completed?
    skill_level.present? && teamwork.present? && manner.present?
  end

  # 콜백
  after_create :notify_evaluated_user

  private

  def notify_evaluated_user
    # 기억에 남는 선수로 선택된 경우에만 알림
    if memorable?
      Notification.create_for_user(
        evaluated_user,
        "evaluation_received",
        {
          title: "🌟 기억에 남는 선수로 선정!",
          message: "#{game.title} 경기에서 누군가가 당신을 기억에 남는 선수로 선정했습니다!",
          data: {
            game_id: game.id,
            game_title: game.title,
            evaluation_id: id
          },
          priority: "normal"
        }
      )
    end
  rescue => e
    Rails.logger.error "Failed to create evaluation notification: #{e.message}"
  end
end
