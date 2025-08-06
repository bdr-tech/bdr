class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:check]
  
  def check
    render json: { 
      status: 'ok',
      rails_env: Rails.env,
      database: check_database,
      time: Time.current
    }
  end
  
  private
  
  def check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    'connected'
  rescue StandardError => e
    "error: #{e.message}"
  end
end