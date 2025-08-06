class OutdoorCourt < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :image1, presence: true
  validates :image2, presence: true
  validates :latitude, presence: true, numericality: { greater_than: -90, less_than: 90 }
  validates :longitude, presence: true, numericality: { greater_than: -180, less_than: 180 }
  validates :address, presence: true, length: { minimum: 10, maximum: 200 }

  scope :recent, -> { order(created_at: :desc) }
  scope :nearby, ->(lat, lng, distance = 10) {
    where(
      "6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))) < ?",
      lat, lng, lat, distance
    )
  }

  def distance_from(latitude, longitude)
    return nil unless latitude && longitude

    # Haversine formula to calculate distance
    earth_radius = 6371 # km

    lat1_rad = Math::PI * self.latitude / 180
    lat2_rad = Math::PI * latitude / 180
    delta_lat = Math::PI * (latitude - self.latitude) / 180
    delta_lng = Math::PI * (longitude - self.longitude) / 180

    a = Math.sin(delta_lat/2) * Math.sin(delta_lat/2) +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) *
        Math.sin(delta_lng/2) * Math.sin(delta_lng/2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

    (earth_radius * c).round(2)
  end

  def google_maps_url
    "https://www.google.com/maps?q=#{latitude},#{longitude}"
  end
end
