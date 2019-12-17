class TwitterController < ApplicationController
  include ActionController::Live

  def tweets
    if request.format.json?
      stream_tweet
    end
  end

  def word_cloud
    client = TwitterFactory.new_rest_client
    tweets = client.search("#Byjus")
    @text_string = ""
    tweets.each do |tweet|
      @text_string += tweet.text
      @text_string += ". "
    end
  end

  private

  # Please note that I used SSE for live streaming on REST API
  # due to time constraints, but it is not a good approach for for blocking
  # servers, as every request will block a thread or process causing resource exhausation.
  # A better approached would be using some event based servers like the 'eventmachine'
  def stream_tweet
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream)
    begin
      stream_client = TwitterFactory.new_streaming_client
      topic = params[:source]
      filter_options = {}
      if topic.present?
        if topic[0] == '@'
          rest_client = TwitterFactory.new_rest_client
          user = rest_client.user(topic[1..-1])
          filter_options[:follow] = user.id
        elsif topic[0] == '#'
          filter_options[:track] = topic # may need to remove '#'
        end
        stream_client.filter(filter_options) do |object|
          if object.is_a?(Twitter::Tweet)
            tweet = object.to_hash
            p tweet
            sse.write(tweet)
          end
        end
      else
        sse.write({error: "No topic"})
      end
    rescue IOError
    rescue ClientDisconnected
      # Client Disconnected
    ensure
      sse.close
    end
    render nothing: true
  end
end
