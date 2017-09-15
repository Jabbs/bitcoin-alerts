class Simulation < ActiveRecord::Base
  has_many :orders, dependent: :destroy
  belongs_to :scheme

  def self.generate_standard(scheme=Scheme.last, print_final_results=false)
    starting_quote_id = 8091
    ending_quote_id = 134052
    usd_starting_account_balance = 3000
    btc_starting_account_balance = 0.0
    eth_starting_account_balance = 0.0
    ltc_starting_account_balance = 0.0
    generate(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance, print_final_results)
  end

  def self.generate(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance, print_final_results=false)
    ActiveRecord::Base.logger.level = 1
    Quote.update_all(passing_strategy_ids: [])
    Coin.all.each(&:destroy)
    simulation = create_from(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
    return unless simulation.present?
    began_simulation_time = DateTime.now
    puts "-----------------------------------------------------------------------"
    puts "##{simulation.id} | Quotes #{starting_quote_id}-#{ending_quote_id}. Scheme ##{scheme.id}."
    puts "-----------------------------------------------------------------------"
    Quote.where(id: [starting_quote_id..ending_quote_id]).order(:traded_at).each do |quote|
      quote.assign_passing_strategies(scheme.strategies)
      scheme.make_trades(quote, simulation)
    end
    end_simulation_time = DateTime.now
    simulation.update_attribute(:completed_at, end_simulation_time)
    simulation.reload.print_results if print_final_results
    puts "-----------------------------------------------------------------------"
    puts "Finished in #{end_simulation_time.to_i - began_simulation_time.to_i} seconds."
    puts "-----------------------------------------------------------------------"
  end

  def self.create_from(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
    attrs = {
      scheme_id: scheme.id,
      starting_quote_id: starting_quote_id,
      ending_quote_id: ending_quote_id,
      usd_starting_account_balance: usd_starting_account_balance,
      btc_starting_account_balance: btc_starting_account_balance,
      eth_starting_account_balance: eth_starting_account_balance,
      ltc_starting_account_balance: ltc_starting_account_balance
    }
    attrs[:usd_account_balance] = usd_starting_account_balance
    attrs[:btc_account_balance] = btc_starting_account_balance
    attrs[:eth_account_balance] = eth_starting_account_balance
    attrs[:ltc_account_balance] = ltc_starting_account_balance
    simulation = Simulation.create!(attrs)
    simulation
  end

  def print_results
    ActiveRecord::Base.logger.level = 1
    hours = (Quote.find(self.ending_quote_id).traded_at - Quote.find(self.starting_quote_id).traded_at).to_i / 60 / 60
    puts "-----------------------------------------------------------------------"
    puts "-----------------------------------------------------------------------"
    puts "##{self.id} | #{Quote.find(self.starting_quote_id).traded_at_with_pretty_cst_time} - #{Quote.find(self.ending_quote_id).traded_at_with_pretty_cst_time} (~#{hours} hrs)"
    self.scheme.strategies.each do |strategy|
      puts "-----------------------------------------------------------------------"
      puts "#{strategy.category.upcase} RULES:"
      puts "-----------------------------------------------------------------------"
      puts "#{strategy.trade_percent_of_account_balance}% of balance"
      strategy.print_rule_descriptions
    end
    puts "-----------------------------------------------------------------------"
    puts "STARTING BALANCES:"
    puts "-----------------------------------------------------------------------"
    ["usd", "btc", "ltc", "eth"].each do |coin|
      m = coin + "_starting_account_balance"
      puts "#{coin.upcase}: #{self.send(m).to_s}"
    end
    puts "Starting value: $#{self.starting_account_value.round(2).to_s}"
    puts "-----------------------------------------------------------------------"
    puts "ENDING BALANCES:"
    puts "-----------------------------------------------------------------------"
    ["usd", "btc", "ltc", "eth"].each do |coin|
      m = coin + "_account_balance"
      puts "#{coin.upcase}: #{self.send(m).to_s}"
    end
    puts "Ending value: $#{self.ending_account_value.round(2).to_s}"
    puts "-----------------------------------------------------------------------"
    puts "ORDERS:"
    puts "-----------------------------------------------------------------------"
    self.orders.order(:created_at).each do |order|
      puts "##{order.id} #{order.side.titleize} #{order.size} #{order.currency}, Quote ##{order.quote.id} #{order.quote.traded_at.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
    end
    puts "Buys: #{self.orders.where(side: "buy").count}"
    puts "Sells: #{self.orders.where(side: "sell").count}"
    puts "-----------------------------------------------------------------------"
    puts "MARKET PERCENT CHANGES:"
    puts "-----------------------------------------------------------------------"
    ["btc", "ltc", "eth"].each do |coin|
      puts "#{coin.upcase}: %#{self.coin_percent_change(coin)}"
    end
    puts "-----------------------------------------------------------------------"
    puts "VALUE PERCENT CHANGE:"
    puts "-----------------------------------------------------------------------"
    puts "%#{self.value_percent_change}"
    puts "-----------------------------------------------------------------------"
    puts "-----------------------------------------------------------------------"
    return true
  end

  def value_percent_change
    Numbers.percent_change(self.ending_account_value, self.starting_account_value)
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
