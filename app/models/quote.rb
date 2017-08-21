class Quote < ActiveRecord::Base
  validates :bid, presence: true
  validates :ask, presence: true
  validates :price, presence: true
  validates :size, presence: true
  validates :volume, presence: true
  validates :currency_pair, presence: true
  validates :trade_id, presence: true, uniqueness: true
  validates :traded_at, presence: true

  def self.check_strategies(quote=recent_quote)
    raise "No recent quote for comparison!" unless quote.present?
    Strategy.all.each do |strategy|
      next if strategy.last_alert_sent_at.present? && strategy.last_alert_sent_at > 30.minutes.ago
      message = strategy.check_for_message(quote)
      if message.present?
        Quote.send_slack_notification(message)
        strategy.update_column(:last_alert_sent_at, Time.zone.now)
      end
    end
  end

  def self.recent_quote(lookback_minutes=2)
    Quote.where("traded_at > ?", lookback_minutes.minutes.ago).try(:first)
  end

  def self.send_slack_notification(message)
    client = Slack::Web::Client.new
    channel = Rails.env.production? ? "#bitcoin-alerts" : "#transactions-dev"
    username = "Bitcoinbot"
    icon_url = "https://image.freepik.com/free-icon/bitcoin-btc_318-41696.jpg"
    message = "<!channel>   " + message
    client.chat_postMessage(channel: channel, text: message.html_safe, as_user: false, username: username, icon_url: icon_url)
  end

  def pretty_cst_time
    self.traded_at.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")
  end
end
