require 'twitter_factory'
class TwitterWorker
  def self.start_stream(topic)
    @redis = RedisClient.new_client

    @stream_thread.kill if @stream_thread
    @stream_thread = Thread.new do
      begin
        @stream_client = TwitterFactory.new_streaming_client
        filter_options = {}
        if topic[0] == '@'
          filter_options[:follow] = topic[1..-1]
        elsif topic[0] == '#'
          filter_options[:track] = topic # may need to remove '#'
        end
        raise "No topic given" if filter_options.empty?
        @stream_client.filter(filter_options) do |object|
          # Check if stream return is a tweet
          if object.is_a?(Twitter::Tweet)
            tweet = object.to_hash
            # Publish tweet to subscribed channel of all users who
            # subscribed to this topic
            ActionCable.server.broadcast(
              "tweets_#{topic}",
              tweet
            )
          end
        end
      rescue
        puts "Something went wrong"
        Thread.exit
      end
    end
    @stream_thread.name = "tweet_topic_#{topic}"
  end

  def self.start_worker_for(topic)
    start_stream(topic)
  end

  def self.stop_worker_for(topic)
    Thread.list.each{ |t| t.kill if t.name == "tweet_topic_#{topic}" }
  end

  def self.stop_all_workers
    Thread.list.each{ |t| t.kill if t.name.start_with("tweet_topic_") }
  end
end