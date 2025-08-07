require 'sinatra'

get '/' do
  '<h1>BDR App is Running!</h1><p>This is a test deployment on Render.</p>'
end

get '/test' do
  "Ruby #{RUBY_VERSION} - Sinatra App"
end