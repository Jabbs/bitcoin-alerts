require 'coinbase/exchange'
namespace :bitcoin do
  desc 'Get quote from Coinbase'
  task :get_quote => :environment do
    CoinbaseService.sync_all_trades
    CoinbaseService.sync_all_quotes
    Scheme.process(Quote.recent_quotes)
  end
end
