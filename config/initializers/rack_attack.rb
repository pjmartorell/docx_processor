class Rack::Attack
  # Use memory store for caching. Even it is not shared between processes, we are running
  # a single process for production.
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle requests to 20 requests per minute per IP address
  Rack::Attack.throttle('req/ip', limit: 20, period: 1.minute) do |req|
    req.ip
  end
end
