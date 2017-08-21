class BitcoinQuote < ActiveRecord::Base
  validates :bid, presence: true
  validates :ask, presence: true
  validates :spot, presence: true
  validates :currency, presence: true

  def self.check_strategies(quote=recent_quote)
    raise "No recent quote for comparison!" unless quote.present?
    Strategy.all.each do |strategy|
      next if strategy.last_alert_sent_at.present? && strategy.last_alert_sent_at > 30.minutes.ago
      message = quote.check_for_buy_strategy_message(strategy.percent_change, strategy.lookback_hours)
      if message.present?
        BitcoinQuote.send_slack_notification(message)
        strategy.update_column(:last_alert_sent_at, Time.zone.now)
      end
    end
  end

  def self.recent_quote(lookback_minutes=2)
    BitcoinQuote.where("created_at > ?", lookback_minutes.minutes.ago).try(:first)
  end

  def self.send_slack_notification(message)
    client = Slack::Web::Client.new
    channel = Rails.env.production? ? "#bitcoin-alerts" : "#transactions-dev"
    username = "Bitcoinbot"
    icon_url = "https://image.freepik.com/free-icon/bitcoin-btc_318-41696.jpg"
    message = "<!channel>   " + message
    client.chat_postMessage(channel: channel, text: message.html_safe, as_user: false, username: username, icon_url: icon_url)
  end

  def check_for_buy_strategy_message(percent_decrease, lookback_hours)
    current_amt = self.ask
    BitcoinQuote.where("created_at > ?", self.created_at - lookback_hours.hours).where("created_at < ?", self.created_at).order("created_at desc").each do |quote|
      previous_amt = quote.ask
      percent_change = Numbers.percent_change(current_amt, previous_amt)
      if percent_change <= -percent_decrease
        strategy = "_#{percent_decrease}% THRESHOLD HIT (LOOKING BACK #{lookback_hours} HOURS)_ \n"
        return "#{strategy}   *#{percent_change}%*   ($#{previous_amt.round(2)} -> $#{current_amt.round(2)})   |   #{quote.pretty_cst_time} -> #{self.pretty_cst_time}"
      end
    end
    ""
  end

  def pretty_cst_time
    self.created_at.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")
  end
end
