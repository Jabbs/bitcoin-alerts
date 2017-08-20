require 'coinbase/wallet'
namespace :bitcoin do
  desc 'Get all Nasdaq stock quotes'
  task :get_quote => :environment do
    client = Coinbase::Wallet::Client.new(api_key: "", api_secret: "")
    ask = client.buy_price({currency_pair: 'BTC-USD'})["amount"].to_f
    bid = client.sell_price({currency_pair: 'BTC-USD'})["amount"].to_f
    spot = client.spot_price({currency_pair: 'BTC-USD'})["amount"].to_f
    BitcoinQuote.create!(bid: bid, ask: ask, spot: spot, currency: "USD")
  end
end
