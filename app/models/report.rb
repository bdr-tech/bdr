class Report < ApplicationRecord
  validates :name, presence: true
  validates :query, presence: true
  validates :schedule, inclusion: { in: %w[daily weekly monthly on_demand] }

  scope :active, -> { where(active: true) }
  scope :by_schedule, ->(schedule) { where(schedule: schedule) }

  def execute
    result = ActiveRecord::Base.connection.execute(query)
    update(last_run: Time.current)
    result
  end

  def self.seed_defaults
    defaults = [
      {
        name: "일일 사용자 통계",
        description: "일일 신규 가입자, 활성 사용자, 경기 생성 등의 통계",
        query: <<~SQL.strip,
          SELECT#{' '}
            DATE(created_at) as date,
            COUNT(*) as new_users,
            COUNT(CASE WHEN status = 'active' THEN 1 END) as active_users
          FROM users#{' '}
          WHERE created_at >= date('now', '-30 days')
          GROUP BY DATE(created_at)
          ORDER BY date DESC
        SQL
        schedule: "daily"
      },
      {
        name: "경기 성과 리포트",
        description: "경기 생성, 참가, 완료율 등의 통계",
        query: <<~SQL.strip,
          SELECT#{' '}
            DATE(created_at) as date,
            COUNT(*) as games_created,
            AVG(application_count) as avg_applications,
            AVG(completion_rate) as avg_completion_rate,
            SUM(revenue_generated) as total_revenue
          FROM games#{' '}
          WHERE created_at >= date('now', '-30 days')
          GROUP BY DATE(created_at)
          ORDER BY date DESC
        SQL
        schedule: "daily"
      },
      {
        name: "결제 통계",
        description: "결제 완료율, 환불률, 수수료 수익 등의 통계",
        query: <<~SQL.strip,
          SELECT#{' '}
            DATE(created_at) as date,
            COUNT(*) as total_payments,
            COUNT(CASE WHEN status = 'paid' THEN 1 END) as completed_payments,
            COUNT(CASE WHEN status = 'refunded' THEN 1 END) as refunded_payments,
            SUM(amount) as total_amount,
            SUM(fee_amount) as total_fees
          FROM payments#{' '}
          WHERE created_at >= date('now', '-30 days')
          GROUP BY DATE(created_at)
          ORDER BY date DESC
        SQL
        schedule: "daily"
      },
      {
        name: "주간 활성 사용자 리포트",
        description: "주간 활성 사용자 및 참여 패턴 분석",
        query: <<~SQL.strip,
          SELECT#{' '}
            strftime('%Y-%W', last_activity_at) as week,
            COUNT(DISTINCT id) as active_users,
            AVG(total_games_participated) as avg_games_per_user,
            AVG(reliability_score) as avg_reliability
          FROM users#{' '}
          WHERE last_activity_at >= date('now', '-8 weeks')
          GROUP BY strftime('%Y-%W', last_activity_at)
          ORDER BY week DESC
        SQL
        schedule: "weekly"
      }
    ]

    defaults.each do |report_config|
      next if exists?(name: report_config[:name])
      create!(report_config)
    end
  end
end
