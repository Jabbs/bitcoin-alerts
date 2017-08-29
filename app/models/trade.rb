class Trade < ActiveRecord::Base
  require 'net/http'
  require 'json'

  validates :trade_id, presence: true, uniqueness: true

  def self.run(currency_pair="LTC-USD")
    uri = URI("https://api.gdax.com/products/#{currency_pair}/trades")
    recent_trade_ids = []

    while true do
      response = Net::HTTP.get(uri)
      JSON.parse(response).each do |t|
        next if recent_trade_ids.include?(t["trade_id"])
        if t["size"].to_f > 100
          puts "#{t["side"].upcase} #{t["size"]} #{t["price"].to_f.round(2)}"
          recent_trade_ids << t["trade_id"]
        end
      end

      sleep 0.34
    end

  end

  def self.get_book
    uri = URI("https://api.gdax.com/products/LTC-USD/book?level=2")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

end
