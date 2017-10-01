namespace :update_btc do
  desc 'Update btc price'
  task :bittrex => :environment do
    offset = 0
    batch_size = 500
    (BittrexMarketSummary.where(btc_price: nil).count/batch_size + 1).times do
      BittrexMarketSummary.where(btc_price: nil).offset(offset).first(batch_size).each do |bms|
        bms.update_attribute(:btc_price, bms.recent_btc_price)
      end
      puts "finished #{offset}"
      offset += batch_size
    end
  end

  task :poloniex => :environment do
    offset = 0
    batch_size = 500
    (PoloniexQuote.where(btc_price: nil).count/batch_size + 1).times do
      PoloniexQuote.where(btc_price: nil).offset(offset).first(batch_size).each do |pq|
        pq.update_attribute(:btc_price, pq.recent_btc_price)
      end
      puts "finished #{offset}"
      offset += batch_size
    end
  end
end
