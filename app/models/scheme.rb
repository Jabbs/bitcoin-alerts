class Scheme < ActiveRecord::Base
  require 'coinbase/exchange'
  has_many :orders

  def self.process(quotes)
    logger.info "STARTED PROCESSING SCHEME #{self.id} FOR #{quotes.pluck(:id)}. #{DateTime.now.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
    quotes.each do |quote|
      quote.assign_passing_strategies(Strategy.all)
      scheme = Scheme.where(state: "active").first
      next unless scheme.present?
      scheme.make_trades(quote)
    end
    logger.info "STOPPED PROCESSING SCHEME #{self.id} FOR #{quotes.pluck(:id)}. #{DateTime.now.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
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
