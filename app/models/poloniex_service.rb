class PoloniexService < ActiveRecord::Base

  def self.sync_poloniex_quotes
    ActiveRecord::Base.logger.level = 1
    uri = URI("https://poloniex.com/public?command=returnTicker")
    response = Net::HTTP.get(uri)
    response = JSON.parse(response)

    btc_price = response["USDT_BTC"]["last"]

    response.keys.each do |currency_pair|
      attrs = {}
      data = response[currency_pair]
      data.each do |k,v|
        attrs[k.underscore] = v unless k == "id"
      end
      attrs["currency_pair"] = currency_pair
      attrs[btc_price] = btc_price
      PoloniexQuote.create(attrs)
    end

    return true
  end
end
