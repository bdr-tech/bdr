module RatingHelper
  def basketball_rating_display(rating)
    rating = rating.to_f
    full_balls = rating.floor
    has_half = (rating % 1) >= 0.5
    empty_balls = 5 - full_balls - (has_half ? 1 : 0)
    percentage = (rating / 5.0 * 100).round

    content_tag(:div, class: "flex items-center space-x-1") do
      html = ""

      # Full basketballs
      full_balls.times do
        html += content_tag(:span, "🏀", class: "text-2xl")
      end

      # Half basketball
      if has_half
        html += content_tag(:span, "🏀", class: "text-2xl opacity-50")
      end

      # Empty basketballs
      empty_balls.times do
        html += content_tag(:span, "⚪", class: "text-2xl opacity-30")
      end

      # Percentage
      html += content_tag(:span, "#{percentage}%", class: "ml-2 text-lg font-semibold text-gray-700")

      html.html_safe
    end
  end

  def user_rating_summary(user)
    rating = user.average_rating
    count = user.rating_count

    content_tag(:div, class: "flex items-center space-x-2") do
      html = ""

      # Basketball rating display (compact version)
      full_balls = rating.floor
      has_half = (rating % 1) >= 0.5
      percentage = (rating / 5.0 * 100).round

      # Show only 3 balls for compact display
      if full_balls >= 3
        html += content_tag(:span, "🏀", class: "text-sm")
        html += content_tag(:span, "🏀", class: "text-sm")
        html += content_tag(:span, "🏀", class: "text-sm")
      elsif full_balls == 2
        html += content_tag(:span, "🏀", class: "text-sm")
        if has_half
          html += content_tag(:span, "🏀", class: "text-sm opacity-50")
        else
          html += content_tag(:span, "🏀", class: "text-sm")
        end
        html += content_tag(:span, "⚪", class: "text-sm opacity-30")
      elsif full_balls == 1
        html += content_tag(:span, "🏀", class: "text-sm")
        html += content_tag(:span, "⚪", class: "text-sm opacity-30")
        html += content_tag(:span, "⚪", class: "text-sm opacity-30")
      else
        html += content_tag(:span, "⚪", class: "text-sm opacity-30")
        html += content_tag(:span, "⚪", class: "text-sm opacity-30")
        html += content_tag(:span, "⚪", class: "text-sm opacity-30")
      end

      # Percentage and count with default indicator
      if count == 0
        html += content_tag(:span, "#{percentage}% (기본)", class: "text-sm font-semibold text-gray-500")
      else
        html += content_tag(:span, "#{percentage}% (#{count})", class: "text-sm font-semibold text-gray-700")
      end

      html.html_safe
    end
  end
end
