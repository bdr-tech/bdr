class SystemSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :category, presence: true

  scope :by_category, ->(category) { where(category: category) }
  scope :editable, -> { where(editable: true) }

  def self.get(key)
    find_by(key: key)&.value
  end

  def self.set(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.save!
  end

  def self.categories
    distinct.pluck(:category)
  end

  # 시스템 설정 초기값
  def self.seed_defaults
    defaults = {
      "platform_fee_percentage" => { value: "5.0", description: "플랫폼 수수료 비율 (%)", category: "payment" },
      "max_games_per_user" => { value: "10", description: "사용자당 최대 경기 생성 수", category: "game" },
      "payment_deadline_hours" => { value: "24", description: "결제 마감 시간 (시간)", category: "payment" },
      "auto_refund_hours" => { value: "2", description: "자동 환불 시간 (시간)", category: "payment" },
      "min_profile_completion" => { value: "70", description: "최소 프로필 완성도 (%)", category: "user" },
      "max_cancellation_per_week" => { value: "3", description: "주간 최대 취소 횟수", category: "user" },
      "site_maintenance_mode" => { value: "false", description: "사이트 점검 모드", category: "system" },
      "site_name" => { value: "BDR - Basketball Reservation", description: "사이트 이름", category: "system" },
      "contact_email" => { value: "support@bdr.com", description: "문의 이메일", category: "system" },
      "max_file_size_mb" => { value: "10", description: "최대 파일 크기 (MB)", category: "system" }
    }

    defaults.each do |key, config|
      next if exists?(key: key)
      create!(
        key: key,
        value: config[:value],
        description: config[:description],
        category: config[:category]
      )
    end
  end
end
