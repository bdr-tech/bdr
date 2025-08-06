#!/usr/bin/env bash
# exit on error
set -o errexit

echo "Starting build process..."

# Install dependencies
echo "Installing dependencies..."
bundle install

# Asset precompilation
echo "Precompiling assets..."
bundle exec rake assets:precompile

# Clean up old assets
echo "Cleaning old assets..."
bundle exec rake assets:clean

# Run database migrations
echo "Running database migrations..."
bundle exec rake db:migrate || echo "Migration failed, but continuing..."

echo "Build process completed!"

# Seed database if this is the first deployment
# Uncomment the following line if you want to seed on first deploy
# bundle exec rake db:seed