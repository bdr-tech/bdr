module ApplicationHelper
  def get_color_code(color_name)
    color_map = {
      "흰색" => "#FFFFFF",
      "검은색" => "#000000",
      "빨간색" => "#EF4444",
      "파란색" => "#3B82F6",
      "노란색" => "#EAB308",
      "초록색" => "#22C55E",
      "회색" => "#6B7280",
      "주황색" => "#F97316",
      "보라색" => "#A855F7",
      "분홍색" => "#EC4899",
      "하늘색" => "#0EA5E9",
      "갈색" => "#A3A3A3"
    }

    color_map[color_name] || "#6B7280"
  end

  def get_uniform_color_code(color_value)
    color_map = {
      "white" => "#FFFFFF",
      "black" => "#000000",
      "blue" => "#3B82F6",
      "yellow" => "#EAB308",
      "red" => "#EF4444"
    }

    color_map[color_value] || "#6B7280"
  end

  def calculate_percentage(made, attempted)
    return 0.0 if attempted == 0
    (made.to_f / attempted * 100).round(1)
  end

  def tournament_status_color(status)
    case status
    when "draft"
      "secondary"
    when "pending_approval"
      "warning"
    when "published"
      "info"
    when "registration_open"
      "success"
    when "registration_closed"
      "secondary"
    when "ongoing"
      "primary"
    when "completed"
      "dark"
    when "cancelled"
      "danger"
    when "rejected"
      "danger"
    else
      "secondary"
    end
  end

  def achievement_category_name(category)
    names = {
      "participation" => "참가",
      "host" => "호스트",
      "social" => "소셜",
      "skill" => "실력",
      "special" => "특별"
    }
    names[category] || category
  end

  def format_currency(amount)
    "#{number_with_delimiter(amount)}원"
  end
end
