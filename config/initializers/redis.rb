# Redis configuration for caching
# This initializer sets up Redis connection pool for Rails cache store

require "connection_pool"
require "redis"

# Redis connection configuration
REDIS_CONFIG = {
  host: ENV.fetch("REDIS_HOST", "localhost"),
  port: ENV.fetch("REDIS_PORT", 6379),
  db: ENV.fetch("REDIS_DB", 0),
  password: ENV["REDIS_PASSWORD"],
  timeout: 5,
  reconnect_attempts: 3,
  reconnect_delay: 0.5,
  reconnect_delay_max: 5.0
}.compact

# Create a connection pool for Redis
REDIS_POOL = ConnectionPool.new(size: 10, timeout: 5) do
  Redis.new(REDIS_CONFIG)
end

# Configure Rails cache store
Rails.application.configure do
  if Rails.env.production? || Rails.env.development? && Rails.root.join("tmp/caching-dev.txt").exist?
    config.cache_store = :redis_cache_store, {
      url: "redis://#{REDIS_CONFIG[:host]}:#{REDIS_CONFIG[:port]}/#{REDIS_CONFIG[:db]}",
      password: REDIS_CONFIG[:password],
      expires_in: 1.hour,
      namespace: "bdr_#{Rails.env}",
      pool_size: 10,
      pool_timeout: 5,

      error_handler: ->(method:, returning:, exception:) {
        Rails.logger.error "[Redis Cache] Error in #{method}: #{exception.class} - #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n") if Rails.env.development?
      },

      # Compression settings
      compress: true,
      compress_threshold: 1.kilobyte,

      # Connection pool settings
      connect_timeout: 2,
      read_timeout: 1,
      write_timeout: 1,
      reconnect_attempts: 3
    }
  end
end

# Helper method to access Redis directly if needed
module RedisHelper
  def self.with_redis(&block)
    REDIS_POOL.with(&block)
  end

  def self.flushdb
    with_redis(&:flushdb) if Rails.env.test? || Rails.env.development?
  end
end
