class TwitterService < ActiveRecord::Base
  def self.client
    if !@client.present?
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
      end
    end
    @client
  end

  def self.positive_engagement_counts(user="Cointelegraph", keywords=["Bitcoin"])
    analyzer = Sentimental.new
    # Load the default sentiment dictionaries
    analyzer.load_defaults
    # Set a global threshold
    analyzer.threshold = 0.1
    TwitterService.find_tweets(user, keywords).select { |t| analyzer.sentiment(t.text) == :positive }.map { |t| t.favorite_count + t.retweet_count }
  end

  def self.find_tweets(user="Cointelegraph", keywords=["Bitcoin"])
    client = TwitterService.client
    x = []
    tweets = client.user_timeline(user, {count: 200})
    x += TwitterService.tweets_with_keyword(tweets, keywords)
    1000.times do
      if tweets.count > 1
        max_id = tweets.last.try(:id)
      elsif max_id.present?
        max_id = max_id - 994251203876933633
      end
      next unless max_id.present?
      tweets = client.user_timeline(user, {count: 200, max_id: max_id})
      x += TwitterService.tweets_with_keyword(tweets, keywords)
    end
    x
  end

  def self.tweets_with_keyword(tweets, keywords)
    x = []
    tweets.each do |tweet|
      add_tweet = false
      add_tweet = keywords.all? { |k| tweet.text.downcase.include?(k.downcase) }
      # add_tweet = tweet.hashtags.map { |h| h.text }.any? { |t| t.downcase == hashtag.downcase }
      x << tweet if add_tweet
    end
    x
  end
end
