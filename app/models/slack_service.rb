class SlackService < ActiveRecord::Base

  def self.send_alerts
    currency_pairs = ["BTC-USD", "LTC-USD", "ETH-USD"]
    alert_strategies = [[2,4], [3,6], [4,8], [5,10]]

    currency_pairs.each do |currency_pair|
      quote = Quote.where(currency_pair: currency_pair).order(:id).last
      alert_strategies.each do |alert_strategy|
        percent_change_threshold = alert_strategy[0]
        lookback_in_hours = alert_strategy[1]
        check_alert_strategy(quote, percent_change_threshold, lookback_in_hours)
      end
    end
  end

  def self.check_alert_strategy(quote, percent_change_threshold, lookback_in_hours)
    running_price_average = quote.running_price_average(lookback_in_hours*60)
    percent_change = Numbers.percent_change(quote.price, running_price_average)
    if percent_change.abs > percent_change_threshold
      strategy_text = "_#{percent_change_threshold.to_s}% THRESHOLD HIT (LOOKING BACK #{lookback_in_hours} HOURS)_ \n"
      direction = percent_change > 0 ? "UP" : "DOWN"
      message = "#{strategy_text}   *Recent price quote $#{quote.price.round(2)} is #{direction} #{percent_change.to_s}% (compared to the #{lookback_in_hours} hour running avg: $#{running_price_average.round(2).to_s})*"
      channel = get_channel(quote.currency_pair)
      unless sent_slack_notification?(1, percent_change_threshold, lookback_in_hours, quote.currency_pair)
        send_slack_notification(message, channel)
        SlackNotification.create!(message: message, channel: channel, quote: quote, percent_change_threshold: percent_change_threshold, lookback_in_hours: lookback_in_hours, currency_pair: quote.currency_pair)
      end
    end
  end

  def self.sent_slack_notification?(hour_count, percent_change_threshold, lookback_in_hours, currency_pair)
    SlackNotification.where("created_at > ?", hour_count.hours.ago).where(percent_change_threshold: percent_change_threshold).where(lookback_in_hours: lookback_in_hours).where(currency_pair: currency_pair).any?
  end

  def self.get_channel(currency_pair)
    if currency_pair == "BTC-USD"
      "bitcoin-alerts"
    elsif currency_pair == "LTC-USD"
      "litecoin-alerts"
    elsif currency_pair == "ETH-USD"
      "ethereum-alerts"
    end
  end

  def self.send_slack_notification(message, channel=nil)
    client = Slack::Web::Client.new
    channel = "#transactions-dev" unless Rails.env.production?
    username = "Bitcoinbot"
    icon_url = "https://image.freepik.com/free-icon/bitcoin-btc_318-41696.jpg"
    message = "<!channel>   " + message
    client.chat_postMessage(channel: channel, text: message.html_safe, as_user: false, username: username, icon_url: icon_url)
  end

end
