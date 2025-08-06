# Performance Monitoring Configuration for BDR Project
# This initializer sets up performance monitoring and optimization features

# Enable query logging in development
if Rails.env.development?
  # Log slow queries (queries taking more than 500ms)
  ActiveSupport::Notifications.subscribe "sql.active_record" do |name, start, finish, id, payload|
    duration = (finish - start) * 1000 # Convert to milliseconds

    if duration > 500
      Rails.logger.warn "SLOW QUERY (#{duration.round(2)}ms): #{payload[:sql]}"
      Rails.logger.warn "Called from: #{caller.select { |c| c.include?(Rails.root.to_s) }.first}"
    end
  end

  # Log N+1 queries detection
  if defined?(Bullet)
    Bullet.enable = true
    Bullet.alert = false
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
end

# Performance metrics collection
module PerformanceMonitoring
  class << self
    # Track action performance
    def track_action(controller, action, &block)
      start_time = Time.current
      result = yield
      duration = Time.current - start_time

      Rails.cache.increment("performance:#{controller}##{action}:count")
      Rails.cache.write(
        "performance:#{controller}##{action}:avg_duration",
        calculate_average_duration(controller, action, duration),
        expires_in: 1.hour
      )

      if duration > 1.0 # Log actions taking more than 1 second
        Rails.logger.warn "SLOW ACTION: #{controller}##{action} took #{duration.round(3)}s"
      end

      result
    end

    # Calculate rolling average duration
    def calculate_average_duration(controller, action, new_duration)
      key = "performance:#{controller}##{action}:avg_duration"
      count_key = "performance:#{controller}##{action}:count"

      current_avg = Rails.cache.read(key) || 0
      count = Rails.cache.read(count_key) || 0

      # Calculate new average
      ((current_avg * count) + new_duration) / (count + 1)
    end

    # Get performance metrics
    def get_metrics
      metrics = {}

      # Collect all performance keys
      if Rails.cache.respond_to?(:stats)
        Rails.cache.stats.each do |server, stats|
          metrics[server] = {
            hits: stats["get_hits"],
            misses: stats["get_misses"],
            hit_rate: calculate_hit_rate(stats["get_hits"], stats["get_misses"])
          }
        end
      end

      metrics
    end

    # Monitor cache hit rate
    def cache_hit_rate
      if Rails.cache.respond_to?(:stats)
        total_hits = 0
        total_misses = 0

        Rails.cache.stats.each do |server, stats|
          total_hits += stats["get_hits"].to_i
          total_misses += stats["get_misses"].to_i
        end

        calculate_hit_rate(total_hits, total_misses)
      else
        "N/A"
      end
    end

    private

    def calculate_hit_rate(hits, misses)
      total = hits + misses
      return "0%" if total == 0
      "#{((hits.to_f / total) * 100).round(2)}%"
    end
  end
end

# Add performance tracking to ActionController
if Rails.env.development? || Rails.env.production?
  ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
    controller = payload[:controller]
    action = payload[:action]
    duration = (finish - start) * 1000 # Convert to milliseconds

    # Log slow actions
    if duration > 1000 # Actions taking more than 1 second
      Rails.logger.warn "[PERFORMANCE] Slow action: #{controller}##{action} took #{duration.round}ms"
      Rails.logger.warn "[PERFORMANCE] View: #{payload[:view_runtime].round}ms, DB: #{payload[:db_runtime].round}ms"
    end

    # Track in cache for monitoring
    Rails.cache.write(
      "performance:last_slow_action",
      {
        controller: controller,
        action: action,
        duration: duration,
        view_runtime: payload[:view_runtime],
        db_runtime: payload[:db_runtime],
        timestamp: Time.current
      },
      expires_in: 1.hour
    )
  end
end

# Database query optimization hints
module QueryOptimization
  HINTS = {
    includes: "Use includes() to eager load associations and avoid N+1 queries",
    select: "Use select() to load only required columns",
    joins: "Use joins() for filtering but includes() for loading associations",
    pluck: "Use pluck() instead of map when you need specific columns",
    find_each: "Use find_each() for batch processing large datasets",
    counter_cache: "Add counter_cache: true to associations for count queries",
    indexes: "Ensure indexes exist on foreign keys and frequently queried columns"
  }.freeze

  def self.suggest_optimization(query)
    suggestions = []

    # Check for common issues
    if query.include?(".count") && query.include?("each")
      suggestions << HINTS[:counter_cache]
    end

    if query.match?(/\.(map|collect)\s*\{\s*\|.*\|\s*.*\.([\w_]+)\s*\}/)
      suggestions << HINTS[:pluck]
    end

    if query.include?("all.each")
      suggestions << HINTS[:find_each]
    end

    suggestions
  end
end

# Log memory usage in development
if Rails.env.development?
  # Monitor memory usage
  Thread.new do
    loop do
      memory_usage = `ps -o rss= -p #{Process.pid}`.to_i / 1024 # Convert to MB

      if memory_usage > 500 # Alert if memory usage exceeds 500MB
        Rails.logger.warn "[MEMORY] High memory usage: #{memory_usage}MB"
      end

      sleep 60 # Check every minute
    end
  end
end

Rails.logger.info "[PERFORMANCE] Performance monitoring initialized"
