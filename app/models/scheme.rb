class Scheme < ActiveRecord::Base
  require 'coinbase/exchange'
  has_many :orders

  def self.process(quotes)
    logger.info "STARTED PROCESSING SCHEME FOR #{quotes.pluck(:id)}. #{DateTime.now.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
    scheme = Scheme.where(state: "active").first
    return unless scheme.present?
    quotes.each do |quote|
      quote.assign_passing_strategies(scheme.strategies)
      scheme.make_trades(quote)
    end
    logger.info "STOPPED PROCESSING SCHEME FOR #{quotes.pluck(:id)}. #{DateTime.now.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
  end

  def print_strategies
    self.strategies.each do |strategy|
      puts strategy.name
    end
    return true
  end

  def self.with_strategy(strategy_id)
    Scheme.where("strategy_ids && '{#{strategy_id}}'::int[]")
  end

  def make_trades(quote, simulation=nil)
    strategy = Strategy.choose_highest_priority(quote.passing_strategies)
    return unless strategy.present?
    CoinbaseService.trade(self, strategy, quote, simulation)
  end

  def strategies(category=["buy", "sell"])
    Strategy.where(id: self.strategy_ids).where(category: category)
  end
end
