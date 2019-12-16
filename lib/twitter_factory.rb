module TwitterFactory
  # Have to use our own app account OAuth for the streaming client =(
  def self.new_streaming_client
    Twitter::Streaming::Client.new do |config|
      # hard-coded all keys and tokens for convience purpose
      # these should be managed more securely in production environment
      config.consumer_key        = "ojpro8YDE0ykhB9Choivbt4jF"
      config.consumer_secret     = "FEEFTqeUngKVn5MUJewA1f4JbjtzkqfISfDm7Wn6pVAW5W7mQz"
      config.access_token        = "963930956-tGxvECuCoepPxuJYGiLbbOhDxXwpY728FDWaA8dc"
      config.access_token_secret = "8DkT2a7zCcMO62dQMD58PxlL4WE8aQoikYkvydKOM4aK4"
    end
  end
end
