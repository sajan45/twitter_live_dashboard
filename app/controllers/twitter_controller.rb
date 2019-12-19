class TwitterController < ApplicationController
  include ActionController::Live

  def tweets
    if request.format.json?
      response.headers["Content-Type"] = "text/event-stream"
      response.headers["rack.hijack"] = proc do |stream|
        Thread.new do
          stream_tweet(stream)
        end
      end
      head :ok
    end
  end

  def word_cloud
    tweets = get_tweets_for("#Byjus")
    @text_string = ""
    tweets.each do |tweet|
      @text_string += tweet.text
      @text_string += ". "
    end
  end

  def sentiment
    @tweets_str_arr = []
    tweets = get_tweets_for("#Byjus")
    tweets.each do |tweet|
      @tweets_str_arr << tweet.text
    end
    @scores = []
    if @tweets_str_arr.present?
      @tweets_str_arr.each do |tweet|
        score = analyse_text(tweet).to_s.to_i
        @scores << score if score > -1
      end
    end
    @data = generate_data_for_chart(@scores) if @scores.present?
  end

  private

  # I am using 'Rack hijack' API partially to takeover the connectio and
  # release the thread used by the application server so that it won't block
  # the connection for other users
  def stream_tweet(stream)
    sse = SSE.new(stream)
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
            sse.write(tweet.to_json)
          end
        end
      else
        sse.write({error: "No topic"}.to_json)
      end
    rescue IOError
    # Client Disconnected
    rescue ClientDisconnected
    # rescuing from the below as it seems rails not raising any of the above
    # when client disconnects
    rescue Errno::EPIPE
    ensure
      sse.close
    end
  end

  def get_tweets_for(search_term)
    client = TwitterFactory.new_rest_client
    client.search(search_term)
  end

  def analyse_text(str)
    pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :parse, :sentiment, :pos, :lemma)
    text = StanfordCoreNLP::Annotation.new(str)
    pipeline.annotate(text)

    # 0 = very negative, 1 = negative, 2 = neutral, 3 = positive, and 4 = very positive
    main_sentiment = -1
    # we are considering the sentiment of the longest sentence as the main sentiment,
    # if there are multiple sentences.
    # this can be tweaked to retun some kind of average sentiment of all sentiments
    longest = 0
    text.get(:sentences).each do |sentence|
      tree = StanfordCoreNLP::AnnotationBridge.getAnnotation(sentence, "edu.stanford.nlp.sentiment.SentimentCoreAnnotations$AnnotatedTree")
      label = tree._invoke('label')
      sentiment = StanfordCoreNLP::AnnotationBridge.getAnnotation(label, "edu.stanford.nlp.neural.rnn.RNNCoreAnnotations$PredictedClass")
      sentence_text = sentence.to_s
      if sentence_text.length > longest
        main_sentiment = sentiment
        longest = sentence_text.length
      end
    end
    main_sentiment
  end

  def generate_data_for_chart(scores)
    sentiment_count = Hash.new(0)
    scores.each do |score|
      sentiment_count[score] += 1
    end
    # keep the order of labels as per the score
    sentiment_data = [
      {'label': 'Very Negative', 'percentage': 0},
      {'label': 'Negative', 'percentage': 0},
      {'label': 'Neutral', 'percentage': 0},
      {'label': 'Positive', 'percentage': 0},
      {'label': 'Very Positive', 'percentage': 0},
    ]
    sentiment_count.each do |score, count|
      if count == 0
        percent = 0
      else
        percent = (count.to_f / scores.length) * 100
      end
      sentiment_data[score]["percentage"] = percent.round(2)
    end
    sentiment_data
  end
end
