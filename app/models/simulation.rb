class Simulation < ActiveRecord::Base
  has_many :orders, dependent: :destroy

  def self.kill_all_and_generate
    Simulation.all.each(&:destroy)
    Coin.all.each(&:destroy)
    scheme = Scheme.last
    starting_quote_id = 20
    ending_quote_id = 3237
    usd_starting_account_balance = 3000
    btc_starting_account_balance = 1.5
    eth_starting_account_balance = 0.0
    ltc_starting_account_balance = 0.0
    generate(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
  end

  def self.generate(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
    ActiveRecord::Base.logger.level = 1
    began_simulation_time = DateTime.now
    puts "Starting simulation of quotes #{starting_quote_id}-#{ending_quote_id} with Scheme #{scheme.id}"
    Quote.update_all(passing_strategy_ids: [])
    simulation = find_incomplete_or_create(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
    return unless simulation.present?
    Quote.where(id: [starting_quote_id..ending_quote_id]).order(:traded_at).each do |quote|
      quote.check_and_update_passing_strategy_ids(scheme.strategies)
      scheme.make_trades(quote, simulation)
    end
    end_simulation_time = DateTime.now
    simulation = simulation.reload
    hours = (Quote.find(ending_quote_id).traded_at - Quote.find(starting_quote_id).traded_at).to_i / 60 / 60
    puts "------------------------------------------------"
    puts "Finished simulation in #{end_simulation_time.to_i - began_simulation_time.to_i} seconds."
    puts "------------------------------------------------"
    puts "#{Quote.find(starting_quote_id).traded_at_with_pretty_cst_time} - #{Quote.find(ending_quote_id).traded_at_with_pretty_cst_time} (~ #{hours} hours)"
    puts "------------------------------------------------"
    puts "STARTING BALANCES:"
    puts "------------------------------------------------"
    ["usd", "btc", "ltc", "eth"].each do |coin|
      m = coin + "_starting_account_balance"
      puts "#{coin.upcase}: #{simulation.send(m).to_s}"
    end
    puts "Starting value: #{simulation.starting_account_value.to_s}"
    puts "------------------------------------------------"
    puts "ENDING BALANCES:"
    puts "------------------------------------------------"
    ["usd", "btc", "ltc", "eth"].each do |coin|
      m = coin + "_account_balance"
      puts "#{coin.upcase}: #{simulation.send(m).to_s}"
    end
    puts "Ending value: #{simulation.ending_account_value.to_s}"
    puts "------------------------------------------------"
    puts "STATS:"
    puts "------------------------------------------------"
    puts "Orders: #{simulation.orders.count}"
    puts "Buys: #{simulation.orders.where(side: "buy").count}"
    puts "Sells: #{simulation.orders.where(side: "sell").count}"
    puts "------------------------------------------------"
    puts "COIN PERCENT CHANGES:"
    puts "------------------------------------------------"
    ["btc", "ltc", "eth"].each do |coin|
      puts "#{coin.upcase}: %#{simulation.coin_percent_change(coin)}"
    end
    puts "------------------------------------------------"
    puts "VALUE PERCENT CHANGE:"
    puts "------------------------------------------------"
    puts "%#{Numbers.percent_change(simulation.ending_account_value, simulation.starting_account_value)}"
    puts "------------------------------------------------"
    puts "------------------------------------------------"
  end

  def self.find_incomplete_or_create(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
    attrs = {
      scheme_id: scheme.id,
      starting_quote_id: starting_quote_id,
      ending_quote_id: ending_quote_id,
      usd_starting_account_balance: usd_starting_account_balance,
      btc_starting_account_balance: btc_starting_account_balance,
      eth_starting_account_balance: eth_starting_account_balance,
      ltc_starting_account_balance: ltc_starting_account_balance
    }
    return nil if Simulation.where(attrs).where.not(completed_at: nil).any?
    if Simulation.where(attrs).any?
      simulation = Simulation.where(attrs).first
      simulation.orders.destroy_all
    else
      attrs[:usd_account_balance] = usd_starting_account_balance
      attrs[:btc_account_balance] = btc_starting_account_balance
      attrs[:eth_account_balance] = eth_starting_account_balance
      attrs[:ltc_account_balance] = ltc_starting_account_balance
      simulation = Simulation.create!(attrs)
    end
    simulation
  end

  def starting_account_value
    value = self.usd_starting_account_balance
    prices_hash = Quote.most_recent_currency_prices(self.starting_quote_id)
    prices_hash.each do |k,v|
      m = k.to_s + "_starting_account_balance"
      value += self.send(m) * v
    end
    value
  end

  def ending_account_value
    value = self.usd_account_balance
    prices_hash = Quote.most_recent_currency_prices(self.ending_quote_id)
    prices_hash.each do |k,v|
      m = k.to_s + "_account_balance"
      value += self.send(m) * v
    end
    value
  end

  def starting_market_value
    value = self.usd_starting_account_balance
    prices_hash = Quote.most_recent_currency_prices(self.starting_quote_id)
    prices_hash.each do |k,v|
      m = k.to_s + "_starting_account_balance"
      value += self.send(m) * v
    end
    value
  end

  def coin_percent_change(coin)
    start_prices_hash = Quote.most_recent_currency_prices(self.starting_quote_id)
    end_prices_hash = Quote.most_recent_currency_prices(self.ending_quote_id)
    Numbers.percent_change(end_prices_hash[coin.downcase.to_sym], start_prices_hash[coin.downcase.to_sym])
  end
end
