class Simulation < ActiveRecord::Base
  has_many :orders, dependent: :destroy

  def self.generate(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
    ActiveRecord::Base.logger.level = 1
    began_simulation_time = DateTime.now
    Quote.update_all(passing_strategy_ids: [])
    simulation = find_incomplete_or_create(scheme, starting_quote_id, ending_quote_id, usd_starting_account_balance, btc_starting_account_balance, eth_starting_account_balance, ltc_starting_account_balance)
    return unless simulation.present?
    Quote.where(id: [starting_quote_id..ending_quote_id]).each do |quote|
      quote.check_and_update_passing_strategy_ids(scheme.strategies)
      scheme.make_trades(quote, simulation)
    end
    end_simulation_time = DateTime.now
    puts "finished in #{end_simulation_time.to_i - began_simulation_time.to_i} seconds."
    puts simulation.reload.inspect
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
end
