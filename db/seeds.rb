# require 'csv'
#
# if Rails.env.development?
#   CSV.foreach("lib/assets/bitcoinity_data.csv", headers: true, :encoding => 'windows-1251:utf-8') do |row|
#     time = row[0].to_datetime
#     price = row[5].to_f
#     BitcoinQuote.create!(created_at: time, bid: price, ask: price, spot: price, currency: "USD")
#   end
# end
