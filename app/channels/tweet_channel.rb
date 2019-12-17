class TweetChannel < ApplicationCable::Channel
  def subscribed
    # we are using the source as it is
    # we have to downcase the source if the hashtags or usernames are case-sensitive
    @stream_topic = "tweets_#{params[:source]}"
    stream_from @stream_topic
    # saving the number of connection for a same topic
    @redis ||= RedisClient.new_client
    current_conncted_user = @redis.hincrby('conn_count', @stream_topic, 1)
    if current_conncted_user == 1
      TwitterWorker.start_worker_for(params[:source])
    end
  end

  def unsubscribed
    current_conncted_user = @redis.hincrby('conn_count', @stream_topic, -1)
    if current_conncted_user <= 0
      TwitterWorker.stop_worker_for(params[:source])
    end
  end
end

