class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :depth, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 5 }

  scope :root_comments, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }

  before_validation :set_depth

  def is_reply?
    parent_id.present?
  end

  def is_root?
    parent_id.nil?
  end

  def can_reply?
    depth < 4  # 최대 5단계까지 답글 허용
  end

  def author_name
    user&.nickname || user&.name || "익명"
  end

  def reply_count
    replies.count
  end

  # 댓글 트리 구조로 정렬
  def self.threaded_comments
    root_comments.includes(:user, replies: [ :user, :replies ])
                 .order(created_at: :asc)
  end

  private

  def set_depth
    if parent_id.present? && parent
      self.depth = parent.depth + 1
    else
      self.depth = 0
    end
  end
end
