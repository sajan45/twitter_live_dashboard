require 'twitter_worker'
require 'socket'

# Ensure worker threads close on exit
at_exit do
  TwitterWorker.stop_all_workers
  redis = Redis.new(host: 'localhost', port: 6379, db: 1)
  # just in case application was force killed and was not able to
  # disconnect all WS connections.
  # Need to rework connection count reset logic,
  # deleting hash like below will cause problems if application has
  # multiple instances
  redis.del('conn_count')
end