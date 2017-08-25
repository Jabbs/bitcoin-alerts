require 'coinbase/exchange'
namespace :bitcoin do
  desc 'Get quote from Coinbase'
  task :get_quote => :environment do
    client = Coinbase::Exchange::Client.new("", "", "")
    currency_pairs = ['BTC-USD', 'ETH-USD', 'LTC-USD', 'LTC-BTC', 'ETH-BTC']
    currency_pairs.each do |currency_pair|
      last_trade = client.last_trade(product_id: currency_pair)
      next if Quote.find_by_trade_id(last_trade["trade_id"]).present?
      Quote.create!(
        currency_pair: currency_pair,
        bid: last_trade["bid"].to_f,
        ask: last_trade["ask"].to_f,
        price: last_trade["price"].to_f,
        volume: last_trade["volume"].to_f,
        size: last_trade["size"].to_f,
        traded_at: last_trade["time"].to_datetime,
        trade_id: last_trade["trade_id"]
      )
    end
    Scheme.process(Quote.recent_quotes)
  end
end
