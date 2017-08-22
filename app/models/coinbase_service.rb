class CoinbaseService < ActiveRecord::Base

  def self.trade(strategy, quote)
    if strategy.buy?
      response = buy_limit_order(strategy, quote)
    elsif strategy.sell?
      response = sell_limit_order(strategy, quote)
    end
    handle_order_response(response, strategy, quote)
  end

  def self.buy_limit_order(strategy, quote)
    client, account = get_client_and_account(strategy.currency_pair, "USD")
    amt, price = get_amt_and_price(account, strategy, quote)
    client.buy(amt, price)
  end

  def self.sell_limit_order(strategy, quote)
    client, account = get_client_and_account(strategy.currency_pair, "BTC")
    amt, price = get_amt_and_price(account, strategy, quote)
    client.sell(amt, price)
  end

  def self.get_client_and_account(currency_pair, account_currency)
    client = rest_api(currency_pair)
    account = client.accounts.find { |a| a.currency == account_currency }
    raise "No account found" unless account.present?
    [client, account]
  end

  def self.get_amt_and_price(account, strategy, quote)
    price = quote.price
    amt = Numbers.percent_from_total(BigDecimal(account.balance), strategy.trade_percent_of_account_balance) / price
    [amt.round(8), price]
  end

  def self.handle_order_response(response, strategy, quote)
    if response[:id]
      attrs = convert_response_to_order_attrs(response)
      order = Order.create!(attrs)
      Logger.info "ORDER CREATED. Order: #{order.id}, Strategy: #{strategy.id}, Quote: #{quote.id}."
    else
      Logger.info "ORDER NOT PROCESSED. Strategy: #{strategy.id}, Quote: #{quote.id}."
    end
  end

  def self.convert_response_to_order_attrs(response)
    h = {}
    response.each do |k,v|
      if k == :product_id
        h[:currency_pair] = v
      elsif k == :created_at
        h[k] = v.to_datetime
      elsif k == :type
        h[:order_type] = v
      else
        h[k] = v
      end
    end
    h
  end

  def self.rest_api(currency_pair="BTC-USD")
    api_key = ""; api_secret = ""; api_pass = ""
    if ENV["GDAX_SANDBOX_MODE"] == "true"
      api_key    = ENV["GDAX_SANDBOX_API_KEY"]
      api_secret = ENV["GDAX_SANDBOX_API_SECRET"]
      api_pass   = ENV["GDAX_SANDBOX_API_PASSPHRASE"]
      @client ||= Coinbase::Exchange::Client.new(api_key, api_secret, api_pass, product_id: currency_pair, api_url: "https://api-public.sandbox.gdax.com")
    else
      api_key    = ENV["GDAX_API_KEY"]
      api_secret = ENV["GDAX_API_SECRET"]
      api_pass   = ENV["GDAX_API_PASSPHRASE"]
      @client ||= Coinbase::Exchange::Client.new(api_key, api_secret, api_pass, product_id: currency_pair)
    end
  end
end
