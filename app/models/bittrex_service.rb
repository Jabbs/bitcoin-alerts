class BittrexService < ActiveRecord::Base

  def self.history(currency_pair="BTC-LTC")
    uri = URI("https://bittrex.com/api/v1.1/public/getmarkethistory?market=#{currency_pair}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def self.market_names
    uri = URI("https://bittrex.com/api/v1.1/public/getmarkets")
    response = Net::HTTP.get(uri)
    response = JSON.parse(response)

    market_names = []
    if response["success"]
      response["result"].each do |data|
        market_names << data["MarketName"] if data["IsActive"]
      end
    else
      raise "Bittrex public/getmarkets error: #{response["message"]}"
    end
    market_names
  end

  def self.get_quote(market_name)
    uri = URI("https://bittrex.com/api/v1.1/public/getticker?market=#{market_name}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def self.get_market_summaries
    uri = URI("https://bittrex.com/api/v1.1/public/getmarketsummaries")
    response = Net::HTTP.get(uri)
    response = JSON.parse(response)
    response["result"]
  end
end
