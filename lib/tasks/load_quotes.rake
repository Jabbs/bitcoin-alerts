require 'coinbase/exchange'
namespace :quotes do
  desc 'Get quotes from api'
  task :load => :environment do
    return unless Rails.env.development?
    Quote.destroy_all
    client = Coinbase::Exchange::Client.new("", "", "")
    count = 10
    end_time = Time.now
    trade_id = 1
    # 60 days
    8640.times do |n|
      end_time = end_time - count.minutes
      start_time = end_time - 9.minutes
      trade = client.price_history(start: start_time, end: end_time).try(:first)
      count += 10
      puts "SKIP" unless trade.present?
      next unless trade.present?
      Quote.create!(
        currency_pair: 'BTC-USD',
        bid: trade["close"].to_f,
        ask: trade["close"].to_f,
        price: trade["close"].to_f,
        volume: trade["volume"].to_f,
        size: 10.0.to_f,
        traded_at: trade["start"].to_datetime,
        trade_id: trade_id
      )
      puts trade_id
      trade_id += 1
      sleep 1 if n.odd?
    end
  end
end
