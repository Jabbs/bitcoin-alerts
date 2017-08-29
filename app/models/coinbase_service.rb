class CoinbaseService < ActiveRecord::Base

  CURRENCY_PAIRS = ['BTC-USD', 'ETH-USD', 'LTC-USD', 'LTC-BTC', 'ETH-BTC']

  def self.sync_all_trades
    CURRENCY_PAIRS.each do |currency_pair|
      CoinbaseService.sync_trade(currency_pair)
      sleep 0.34
    end
    return true
  end

  def self.sync_trade(currency_pair="LTC-USD", lookback_seconds=120)
    uri = URI("https://api.gdax.com/products/#{currency_pair}/trades?start=#{Time.now - lookback_seconds.seconds}")
    response = Net::HTTP.get(uri)
    JSON.parse(response).each_with_index do |trade_attrs, index|
      trade_attrs["currency_pair"] = currency_pair
      Trade.create(trade_attrs)
    end
    return true
  end

  def self.sync_all_quotes
    CURRENCY_PAIRS.each do |currency_pair|
      CoinbaseService.sync_quote(currency_pair)
      sleep 0.34
    end
    return true
  end

  def self.sync_quote(currency_pair="LTC-USD")
    client = Coinbase::Exchange::Client.new("", "", "")
    last_trade = client.last_trade(product_id: currency_pair)
    Quote.create(
      currency_pair: currency_pair,
      bid: last_trade["bid"].to_f,
      ask: last_trade["ask"].to_f,
      price: last_trade["price"].to_f,
      volume: last_trade["volume"].to_f,
      size: last_trade["size"].to_f,
      traded_at: last_trade["time"].to_datetime,
      trade_id: last_trade["trade_id"]
    )
  end

  def self.trade(scheme, strategy, quote, simulation=nil)
    response = order(strategy, quote, "market", simulation)
    handle_order_response(response, scheme, strategy, quote, simulation)
  end

  def self.order(strategy, quote, order_type="market", simulation=nil)
    currency = strategy.buy? ? "USD" : strategy.currency_pair.split("-").first
    if simulation.present?
      balance_method = currency.downcase + "_account_balance"
      account = DotHash.load({balance: simulation.send(balance_method).to_s})
      amt, price = get_amt_and_price(order_type, account, strategy, quote)
      # ["btc", "ltc", "eth"].each do |currency|
      #   coins = Wallet.for_trading.coins.send(currency)
      #   puts "#{coins.count} #{currency.upcase} coins"
      # end
      # puts strategy.category.upcase + " " + quote.currency_pair + " - "+ "quote id: #{quote.id}, " + "quote bid: #{quote.bid.to_s}, " + "quote ask: #{quote.ask.to_s}, " + "amt: #{amt}, price: #{price}"
      simulated_api_respone(amt, order_type, strategy, quote, simulation)
    else
      client, account = get_client_and_account(strategy.currency_pair, currency)
      amt, price = get_amt_and_price(order_type, account, strategy, quote)
      params = { type: order_type }
      client.send(strategy.category, amt, price, params)
    end
  end

  def self.get_client_and_account(currency_pair, account_currency)
    client = rest_api(currency_pair)
    account = client.accounts.find { |a| a.currency == account_currency }
    raise "No account found" unless account.present?
    [client, account]
  end

  def self.get_amt_and_price(order_type, account, strategy, quote)
    price = strategy.buy? ? quote.ask : quote.bid
    if strategy.sell?
      amt = Numbers.percent_from_total(account.balance.to_f, strategy.trade_percent_of_account_balance)
    elsif strategy.buy?
      amt = Numbers.percent_from_total(account.balance.to_f, strategy.trade_percent_of_account_balance) / price
    end
    price = nil if order_type == "market"
    [amt.round(8), price]
  end

  def self.handle_order_response(response, scheme, strategy, quote, simulation=nil)
    if response[:id]
      attrs = convert_response_to_order_attrs(response)
      simulation.present? ? attrs[:simulation_id] = simulation.id : attrs[:scheme_id] = scheme.id
      attrs[:quote_id]    = quote.id
      attrs[:strategy_id] = strategy.id
      order = Order.create!(attrs)
    else
      Rails.logger.info "ORDER NOT PROCESSED. Strategy: #{strategy.id}, Quote: #{quote.id}."
    end
  end

  def self.convert_response_to_order_attrs(response)
    h = {}
    response.each do |k,v|
      if k == :id
        h[:client_id] = v
      elsif k == :product_id
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

  def self.simulated_api_respone(amt, order_type, strategy, quote, simulation=nil)
    price = strategy.buy? ? quote.ask : quote.bid
    value = amt*price
    fill_fees = value * 0.0025
    executed_value = value - fill_fees
    filled_size = amt*0.9975
    h = {
      "id": "simulation-" + SecureRandom.urlsafe_base64,
      "size": amt.to_s,
      "product_id": strategy.currency_pair,
      "side": strategy.category,
      "stp": "dc",
      "done_reason": "filled",
      "done_at": DateTime.now.to_s,
      "type": order_type,
      "time_in_force": "GTC",
      "post_only": false,
      "created_at": DateTime.now,
      "fill_fees": fill_fees.to_s,
      "filled_size": filled_size.to_s,
      "executed_value": executed_value.to_s,
      "status": "done",
      "settled": true
    }

    if simulation.present?
      simulation = simulation.reload
      if strategy.buy?
        increment_balance_method = strategy.currency.downcase + "_account_balance"
        new_increment_balance    = simulation.send(increment_balance_method) + filled_size
        decrement_balance_method = :usd_account_balance
        new_decrement_balance    = simulation.send(decrement_balance_method) + (value*(-1))
      elsif strategy.sell?
        increment_balance_method = :usd_account_balance
        new_increment_balance    = simulation.send(increment_balance_method) + executed_value
        decrement_balance_method = strategy.currency.downcase + "_account_balance"
        new_decrement_balance    = simulation.send(decrement_balance_method) + (amt*(-1))
      end
      # puts "#{increment_balance_method} balance: #{simulation.send(increment_balance_method)} -> #{new_increment_balance}"
      # puts "#{decrement_balance_method} balance: #{simulation.send(decrement_balance_method)} -> #{new_decrement_balance}"
      # puts "------------------------------------------------"
      simulation.update_attributes(increment_balance_method => new_increment_balance, decrement_balance_method => new_decrement_balance)
    end

    DotHash.load(h)
  end
end
