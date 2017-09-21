namespace :update_btc do
  desc 'Update btc price'
  task :bittrex => :environment do
    1900.times do |n|
      puts "#{(1900-n).to_s} pages left"
      BittrexMarketSummary.where(btc_price: nil).first(1000).each do |bms|
        bms.update_attribute(:btc_price, bms.recent_btc_price)
      end
    end
  end

  task :poloniex => :environment do
    63.times do |n|
      puts "#{(62-n).to_s} pages left"
      PoloniexQuote.where(btc_price: nil).first(1000).each do |pq|
        pq.update_attribute(:btc_price, bms.recent_btc_price)
      end
    end
  end
end
