class TweetChannel < ApplicationCable::Channel
  def subscribed
    # we are using the source as it is
    # we have to downcase the source if the hashtags or usernames are case-sensitive
    stream_from "tweets_#{params[:source]}"
    # saving the number of connection for a same topic
    current_conncted_user = REDIS_CLIENT.hincrby('conn_count', "#{params[:source]}", 1)
    if current_conncted_user == 1
      # add logic to create new worker for this topic
    end
  end

  def unsubscribed
    current_conncted_user = REDIS_CLIENT.hincrby('conn_count', "#{params[:source]}", -1)
    if current_conncted_user <= 0
      # stop worker for this topic
    end
  end
end

