class BittrexService < ActiveRecord::Base

  def self.sync_market_summaries
    ActiveRecord::Base.logger.level = 1
    uri = URI("https://bittrex.com/api/v1.1/public/getmarketsummaries")
    response = Net::HTTP.get(uri)
    response = JSON.parse(response)

    if response["success"]
      response["result"].each do |data|
        attrs = {}
        data.each do |k,v|
          attrs[k.underscore] = v
        end
        BittrexMarketSummary.create(attrs)
      end
    else
      raise "Bittrex public/getmarkets error: #{response["message"]}"
    end
    return true
  end
end
