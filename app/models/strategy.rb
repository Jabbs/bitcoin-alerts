class Strategy < ActiveRecord::Base
  has_many :rules, dependent: :destroy

  def self.get_return(starting_amount=4000, days=365, percent=1, lot_size=4, lot_wins_per_day=3)
    r = starting_amount.to_f
    days.times do
      l = r.to_f/lot_size.to_f
      a = (l * (1.to_f + percent.to_f/100.to_f)) - l
      r = r + (a*lot_wins_per_day)
    end
    r - starting_amount
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

  def buy?
    self.category == "buy"
  end

  def sell?
    self.category == "sell"
  end

  def currency
    self.currency_pair.split("-")[0]
  end

  def quote_is_passing?(quote)
    return false unless quote.currency_pair == self.currency_pair
    is_passing = false
    if self.rules.with_and_operator.any?
      is_passing = self.rules.with_and_operator.count == self.rules.with_and_operator.select { |rule| rule.quote_is_passing?(quote) }.count
    end
    return true if self.rules.with_and_operator.any? && is_passing
    if self.rules.with_or_operator.any?
      is_passing = self.rules.with_or_operator.select { |rule| rule.quote_is_passing?(quote) }.count > 0
    end
    is_passing
  end
end
