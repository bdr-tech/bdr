class WeatherCheckService
  def initialize(tournament)
    @tournament = tournament
  end
  
  def check_and_notify
    weather_info = fetch_weather_data
    
    if weather_info[:needs_alert]
      send_weather_alert(weather_info)
    end
    
    weather_info
  end
  
  private
  
  def fetch_weather_data
    # In production, this would call a weather API
    # For now, return mock data
    {
      temperature: 25,
      condition: 'sunny',
      rain_probability: 10,
      wind_speed: 5,
      needs_alert: false
    }
  end
  
  def send_weather_alert(weather_info)
    message = generate_weather_message(weather_info)
    
    @tournament.tournament_teams.approved.each do |team|
      NotificationAdapter.create_tournament_notification(
        user: team.captain,
        tournament: @tournament,
        type: 'weather_alert',
        content: message
      )
    end
  end
  
  def generate_weather_message(weather_info)
    if weather_info[:rain_probability] > 70
      "날씨 알림: 비 예보(#{weather_info[:rain_probability]}%)가 있습니다."
    elsif weather_info[:temperature] > 35
      "날씨 알림: 고온(#{weather_info[:temperature]}°C)이 예상됩니다."
    else
      "날씨 알림: 날씨 변화가 예상됩니다."
    end
  end
end