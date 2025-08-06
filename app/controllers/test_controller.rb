class TestController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    render plain: "BDR App is running! Rails #{Rails.version} - Ruby #{RUBY_VERSION}"
  end
end