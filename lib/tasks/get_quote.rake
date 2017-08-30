require 'coinbase/exchange'
namespace :bitcoin do
  desc 'Get quote from Coinbase'
  task :get_quote => :environment do
    begin_time = DateTime.now
    Rails.logger.info "Starting sync. #{begin_time.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
    quotes = CoinbaseService.sync_all_quotes
    quotes.each do |quote|
      CoinbaseService.sync_order_book(quote.currency_pair, quote.id)
      sleep 0.34
      CoinbaseService.sync_trade(quote.currency_pair, quote.id)
      sleep 0.34
    end
    Scheme.process(Quote.recent_quotes)
    end_time = DateTime.now
    Rails.logger.info "Completed sync. #{begin_time.to_i - end_time.to_i} seconds"
  end
end
