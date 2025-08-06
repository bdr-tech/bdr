#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Asset precompilation
bundle exec rake assets:precompile

# Clean up old assets
bundle exec rake assets:clean

# Run database migrations
bundle exec rake db:migrate

# Seed database if this is the first deployment
# Uncomment the following line if you want to seed on first deploy
# bundle exec rake db:seed