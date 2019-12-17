module TwitterFactory
  # static method
  def self.config
    {
      :consumer_key => 'ojpro8YDE0ykhB9Choivbt4jF',
      :consumer_secret => 'FEEFTqeUngKVn5MUJewA1f4JbjtzkqfISfDm7Wn6pVAW5W7mQz',
      :access_token => '963930956-tGxvECuCoepPxuJYGiLbbOhDxXwpY728FDWaA8dc',
      :access_token_secret => '8DkT2a7zCcMO62dQMD58PxlL4WE8aQoikYkvydKOM4aK4'
    }
  end

  def self.new_rest_client
    Twitter::REST::Client.new(config)
  end

  def self.new_streaming_client
    Twitter::Streaming::Client.new(config)
  end
end
