# Simple Rack app for testing
if ENV['RAILS_ENV'] == 'production' && ENV['RAILS_MASTER_KEY'].nil?
  # If Rails master key is missing, run simple Rack app
  run lambda { |env| 
    [200, 
     {'Content-Type' => 'text/html'}, 
     ['<h1>BDR App - Rails Master Key Missing!</h1>
       <p>Please set RAILS_MASTER_KEY environment variable in Render.</p>
       <p>Key: 19476ca4d42323891a0f2c2c00745d2b</p>
       <p>Server is running but Rails cannot start without the key.</p>']] 
  }
else
  # Normal Rails app
  require_relative "config/environment"
  run Rails.application
  Rails.application.load_server
end