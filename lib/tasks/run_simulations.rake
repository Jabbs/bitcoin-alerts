namespace :bitcoin do
  desc 'Create strategies'
  task :run_simulations => :environment do

    starting_quote_id = 20
    ending_quote_id = 4712
    usd_starting_account_balance = 3000
    btc_starting_account_balance = 0.8
    eth_starting_account_balance = 10.0
    ltc_starting_account_balance = 60.0
    1000.times do
      s = Strategy.buy.where(currency_pair: "LTC-USD").shuffle.first
      scheme = Scheme.with_strategy(s.id).shuffle.first
      next if Simulation.where(scheme_id: scheme.id).any?
      Simulation.generate(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
    end
  end
end
