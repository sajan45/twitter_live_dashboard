require 'twitter_worker'
require 'socket'

# Ensure worker threads close on exit
at_exit do
  TwitterWorker.stop_all_workers
end