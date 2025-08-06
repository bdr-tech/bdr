#!/usr/bin/env bash
set -o errexit

echo "==> Installing gems..."
bundle config set --local deployment 'true'
bundle config set --local without 'development test'
bundle install

echo "==> Precompiling assets..."
bundle exec rake assets:precompile

echo "==> Build successful!"