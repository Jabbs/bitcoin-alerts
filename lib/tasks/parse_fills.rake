require 'csv'

namespace :parse do
  desc 'Use combined csv fills (from gdax) to print for google doc: bitcoin/transactions'
  task :gdax_fills => :environment do
    CSV.foreach("lib/assets/fills_gdax_9_15_17.csv", headers: true, :encoding => 'windows-1251:utf-8') do |row|
      trade_id             = row[0]
      currency_pair        = row[1]
      side                 = row[2]
      created_at           = row[3].to_datetime.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y %-l:%M%P")
      size                 = row[4]
      size_unit            = row[5]
      price                = row[6]
      fee                  = row[7]
      total                = row[8]
      price_fee_total_unit = row[9]

      buy_currency = currency_pair.split("-").last
      sell_currency = currency_pair.split("-").first
      source_account = side == "BUY" ? "GDAX #{buy_currency} Wallet" : "GDAX #{sell_currency} Wallet"
      receiving_account = side == "BUY" ? "GDAX #{sell_currency} Wallet" : "GDAX #{buy_currency} Wallet"
      usd_sell = ""; usd_buy = ""; btc_sell = ""; btc_buy = ""; ltc_sell = ""; ltc_buy = ""; eth_sell = ""; eth_buy = "";

      if side == "SELL"
        usd_sell = total if buy_currency == "USD"
        btc_sell = total if buy_currency == "BTC"

        btc_sell = (size.to_f * (-1)).to_s if sell_currency == "BTC"
        ltc_sell = (size.to_f * (-1)).to_s if sell_currency == "LTC"
        eth_sell = (size.to_f * (-1)).to_s if sell_currency == "ETH"
      elsif side == "BUY"
        usd_buy = total if buy_currency == "USD"
        btc_buy = total if buy_currency == "BTC"

        btc_buy = size if sell_currency == "BTC"
        ltc_buy = size if sell_currency == "LTC"
        eth_buy = size if sell_currency == "ETH"
      end



      if price_fee_total_unit == "BTC"
        fee = "," + fee
      end

      puts created_at + "," + trade_id + "," + source_account + "," + receiving_account + "," + usd_sell + "," + usd_buy + ",," + btc_sell + "," + btc_buy + ",," + ltc_sell + "," + ltc_buy + ",," + eth_sell + "," + eth_buy + ",," + fee

    end
  end
end
