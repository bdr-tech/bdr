module PaymentCalculator
  extend ActiveSupport::Concern

  class_methods do
    def calculate_revenue(period_range)
      where(created_at: period_range)
        .where(status: "paid")
        .sum(:amount) || 0
    end

    def calculate_platform_fee(period_range)
      where(created_at: period_range)
        .where(status: "paid")
        .sum(:fee_amount) || 0
    end

    def calculate_host_revenue(period_range)
      where(created_at: period_range)
        .where(status: "paid")
        .sum(:net_amount) || 0
    end

    def today_range
      Date.current.beginning_of_day..Date.current.end_of_day
    end

    def current_month_range
      Date.current.beginning_of_month..Date.current.end_of_month
    end
  end
end
