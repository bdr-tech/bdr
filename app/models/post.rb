class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { minimum: 2, maximum: 100 }
  validates :content, presence: true, length: { minimum: 5 }
  validates :category, presence: true, inclusion: {
    in: %w[자유게시판 중고거래 팀소개 농구코트정보],
    message: "올바른 카테고리를 선택해주세요"
  }

  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }

  # 카테고리 상수
  CATEGORIES = {
    "자유게시판" => "자유롭게 대화를 나누는 공간",
    "중고거래" => "농구 용품 중고 거래",
    "팀소개" => "농구팀 소개 및 모집",
    "농구코트정보" => "농구장 정보 및 후기"
  }.freeze

  def increment_views!
    increment!(:views_count)
  end

  def category_name
    CATEGORIES[category] || category
  end

  def category_icon
    case category
    when "자유게시판"
      "💬"
    when "중고거래"
      "🛒"
    when "팀소개"
      "👥"
    when "농구코트정보"
      "🏀"
    else
      "📝"
    end
  end

  def has_images?
    image1.present? || image2.present?
  end

  def image_count
    [ image1, image2 ].compact.count
  end
end
