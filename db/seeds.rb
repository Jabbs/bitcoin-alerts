# require 'csv'
#
# if Rails.env.development?
#   trade_id = 1
#   CSV.foreach("lib/assets/bitcoinity_data.csv", headers: true, :encoding => 'windows-1251:utf-8') do |row|
#     time = row[0].to_datetime
#     price = row[5].to_f
#     Quote.create!(traded_at: time, currency_pair: "BTC-USD", bid: price, ask: price, price: price, size: 10.0, volume: 10000.0, trade_id: trade_id)
#     trade_id += 1
#   end
# end
