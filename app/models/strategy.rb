class Strategy < ActiveRecord::Base

  def self.get_return(starting_amount, days, percent, lot_size, lot_wins_per_day)
    r = starting_amount.to_f
    days.times do
      l = r.to_f/lot_size.to_f
      a = (l * (1.to_f + percent.to_f/100.to_f)) - l
      r = r + (a*lot_wins_per_day)
    end
    r
  end

  def self.choose_highest_priority(strategies)
    return if strategies.where(category: "hold").any?
    if strategies.where(category: "sell").any?
      strategies.where(category: "sell").first
    elsif strategies.where(category: "buy").any?
      strategies.where(category: "buy").first
    else
      nil
    end
  end

  def self.send_slack_notification(message)
    client = Slack::Web::Client.new
    channel = Rails.env.production? ? "#bitcoin-alerts" : "#transactions-dev"
    username = "Bitcoinbot"
    icon_url = "https://image.freepik.com/free-icon/bitcoin-btc_318-41696.jpg"
    message = "<!channel>   " + message
    client.chat_postMessage(channel: channel, text: message.html_safe, as_user: false, username: username, icon_url: icon_url)
  end

  def send_slack_message(quote)
    return if self.last_alert_sent_at.present? && self.last_alert_sent_at > 30.minutes.ago
    Strategy.send_slack_notification(self.slack_message(quote))
    self.update_column(:last_alert_sent_at, Time.zone.now)
  end

  def slack_message(quote)
    comparison_quote = self.most_recent_passing_quote(quote)
    "#{self.slack_name}\n   *#{Numbers.percent_change(quote.ask, comparison_quote.ask)}%*   ($#{comparison_quote.ask.round(2)} -> $#{quote.ask.round(2)})   |   #{comparison_quote.traded_at_with_pretty_cst_time} -> #{quote.traded_at_with_pretty_cst_time}"
  end

  def most_recent_passing_quote(quote)
    Quote.get_previous_quotes(quote, self.lookback_hours).each do |q|
      if self.percent_change_passes_threshold?(Numbers.percent_change(quote.price, q.price))
        return q
      end
    end
    nil
  end

  def buy?
    self.category == "buy"
  end

  def sell?
    self.category == "sell"
  end

  def quote_is_passing?(quote)
    return false unless quote.currency_pair == self.currency_pair
    self.most_recent_passing_quote(quote).present? ? true : false
  end

  def percent_change_threshold
    self.percent_change_confinment == "floor" ? self.percent_change * (-1) : self.percent_change
  end

  def percent_change_passes_threshold?(percent_change)
    (self.percent_change_confinment == "floor" && percent_change <= self.percent_change_threshold) ||
      (self.percent_change_confinment == "ceiling" && percent_change >= self.percent_change_threshold)
  end

  def slack_name
    "_#{self.percent_change}% THRESHOLD HIT (LOOKING BACK #{self.lookback_hours} HOURS)_"
  end
end
