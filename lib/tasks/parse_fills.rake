require 'csv'

namespace :parse do
  desc 'Use combined csv fills (from gdax) to print for google doc: bitcoin/transactions'
  task :gdax_fills => :environment do
    CSV.foreach("lib/assets/fills_gdax_9_15_17.csv", headers: true, :encoding => 'windows-1251:utf-8') do |row|
      trade_id = row[0].to_i
      currency_pair = row[1]
      side = row[2]
      created_at = row[3].to_datetime
      size = row[4]
      size_unit = row[5]
      price = row[6]
      fee = row[7]
    end
  end
end
