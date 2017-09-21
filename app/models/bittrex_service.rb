class BittrexService < ActiveRecord::Base

  def self.sync_market_summaries
    ActiveRecord::Base.logger.level = 1
    uri = URI("https://bittrex.com/api/v1.1/public/getmarketsummaries")
    response = Net::HTTP.get(uri)
    response = JSON.parse(response)

    if response["success"]
      btc_price = response["result"].select { |r| r["MarketName"] == "USDT-BTC" }.first["Last"]
      eth_price = response["result"].select { |r| r["MarketName"] == "USDT-ETH" }.first["Last"]
      response["result"].each do |data|
        attrs = {}
        data.each do |k,v|
          attrs[k.underscore] = v
        end
        attrs["btc_price"] = btc_price
        attrs["eth_price"] = eth_price
        BittrexMarketSummary.create(attrs)
      end
    else
      raise "Bittrex public/getmarkets error: #{response["message"]}"
    end
    return true
  end
end
