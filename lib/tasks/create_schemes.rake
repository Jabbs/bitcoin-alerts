namespace :bitcoin do
  desc 'Create strategies'
  task :create_schemes => :environment do

    # n = 0.5
    # while n <= 5.0
    #   n += 0.3
    #   n = n.round(1)
    #   currency_pairs = ["BTC-USD", "ETH-USD", "LTC-USD"]
    #   currency_pairs.each do |currency_pair|
    #     trade_percent_of_account_balances = [20, 25, 33]
    #     trade_percent_of_account_balances.each do |trade_percent_of_account_balance|
    #       lookback_minutes_for_percent_decreases = [300,250,200,150]
    #       lookback_minutes_for_percent_decreases.each do |lookback_minutes_for_percent_decrease|
    #         lookback_minutes_for_same_strategies = [200,150,100,50]
    #         lookback_minutes_for_same_strategies.each do |lookback_minutes_for_same_strategy|
    #           buy_s = create_buy_strategy(currency_pair, trade_percent_of_account_balance, n, lookback_minutes_for_percent_decrease, lookback_minutes_for_same_strategy)
    #           percent_increase_firsts = [0.8, 1.2, 1.6, 2.0, 2.4, 2.8, 3.2]
    #           percent_increase_firsts.each do |percent_increase_first|
    #             percent_increase_seconds = [percent_increase_first, percent_increase_first + 0.4, percent_increase_first + 0.8]
    #             percent_increase_seconds.each do |percent_increase_second|
    #               sell_s = create_sell_strategy(currency_pair, trade_percent_of_account_balance, percent_increase_first, percent_increase_second)
    #               s = Scheme.create!(strategy_ids: [buy_s.id, sell_s.id])
    #               puts "Scheme #{s.id} created"
    #             end
    #           end
    #         end
    #       end
    #     end
    #   end
    # end

    currency_pair = "LTC-USD"
    trade_percent_of_account_balance = 100
    percent_decrease = 1.0
    lookback_minutes_for_percent_decrease = 60
    lookback_minutes_for_same_strategy = 50
    percent_increase_first = 1.0
    percent_increase_second = 1.4
    buy_s = create_buy_strategy(currency_pair, trade_percent_of_account_balance, percent_decrease, lookback_minutes_for_percent_decrease, lookback_minutes_for_same_strategy)
    sell_s = create_sell_strategy(currency_pair, trade_percent_of_account_balance, percent_increase_first, percent_increase_second)
    s = Scheme.create!(strategy_ids: [buy_s.id, sell_s.id])
    puts "Scheme #{s.id} created"
  end

  def create_buy_strategy(currency_pair, trade_percent_of_account_balance, percent_decrease, lookback_minutes_for_percent_decrease, lookback_minutes_for_same_strategy)
    attrs = { currency_pair: currency_pair, trade_percent_of_account_balance: trade_percent_of_account_balance, category: "buy" }
    rule_attrs = []
    rule_attrs << { comparison_logic: "wallet_not_full", operator: "and" }
    rule_attrs << { comparison_logic: "wallet_has_one_or_less_coins", operator: "and" }
    rule_attrs << { comparison_logic: "quote_running_average", operator: "and", percent_decrease: percent_decrease, lookback_minutes: lookback_minutes_for_percent_decrease }
    rule_attrs << { comparison_logic: "no_recent_quote_with_same_strategy", operator: "and", lookback_minutes: lookback_minutes_for_same_strategy }
    strategy_name = "Buy #{currency_pair} w %#{attrs[:trade_percent_of_account_balance]} when wallet isnt full, has 0-1 coins, recent quote down #{percent_decrease}% in #{(lookback_minutes_for_percent_decrease.to_f/60.to_f).round(1)}hrs, no quotes within #{(lookback_minutes_for_same_strategy.to_f/60.to_f).round(1)} hours duplicate"
    attrs[:name] = strategy_name
    strategy = Strategy.create!(attrs)
    rule_attrs.each do |rule_attrs|
      strategy.rules.create!(rule_attrs)
    end
    strategy
  end

  def create_sell_strategy(currency_pair, trade_percent_of_account_balance, percent_increase_first, percent_increase_second)
    attrs = { currency_pair: currency_pair, trade_percent_of_account_balance: trade_percent_of_account_balance, category: "sell" }
    rule_attrs = []
    rule_attrs << { comparison_logic: "first_coin_in_wallet", operator: "or", percent_increase: percent_increase_first }
    rule_attrs << { comparison_logic: "last_coin_in_wallet", operator: "or", percent_increase: percent_increase_second }
    strategy_name = "Sell #{currency_pair} when first coin in wallet is up #{percent_increase_first.to_s}% or last coin up #{percent_increase_second.to_s}%"
    attrs[:name] = strategy_name
    strategy = Strategy.create!(attrs)
    rule_attrs.each do |rule_attrs|
      strategy.rules.create!(rule_attrs)
    end
    strategy
  end
end
