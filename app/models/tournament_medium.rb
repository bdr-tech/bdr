class TournamentMedium < ApplicationRecord
  belongs_to :tournament
  belongs_to :user

  MEDIA_TYPES = %w[poster highlight photo certificate banner].freeze

  validates :media_type, inclusion: { in: MEDIA_TYPES }
  validates :title, presence: true
  validates :file_url, presence: true

  scope :posters, -> { where(media_type: "poster") }
  scope :highlights, -> { where(media_type: "highlight") }
  scope :photos, -> { where(media_type: "photo") }
  scope :certificates, -> { where(media_type: "certificate") }
  scope :popular, -> { order(views_count: :desc, likes_count: :desc) }

  def increment_view!
    increment!(:views_count)
  end

  def like!
    increment!(:likes_count)
  end

  def unlike!
    decrement!(:likes_count) if likes_count > 0
  end

  def poster?
    media_type == "poster"
  end

  def certificate?
    media_type == "certificate"
  end
end
