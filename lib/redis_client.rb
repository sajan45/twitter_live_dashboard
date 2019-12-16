module RedisClient
# we should use a connection pool for production apps
  # this way we may exhaust redis resource unnecessarily
  def self.new_client
    Redis.new(host: 'localhost', port: 6379, db: 1)
  end
end
