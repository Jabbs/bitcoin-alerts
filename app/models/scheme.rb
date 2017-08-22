class Scheme < ActiveRecord::Base
  require 'coinbase/exchange'
  ALERTABLE_CURRENCY_PAIRS = ["BTC-USD"]

  def self.process(quotes)
    logger.info "STARTED PROCESSING SCHEME #{self.id} FOR #{quotes.pluck(:id)}. #{DateTime.now.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
    quotes.each do |quote|
      quote.check_and_update_passing_strategy_ids(Strategy.all)
      quote.process_slack_alerts if ALERTABLE_CURRENCY_PAIRS.include?(quote.currency_pair)
      Scheme.make_trades(quote)
    end
    logger.info "STOPPED PROCESSING SCHEME #{self.id} FOR #{quotes.pluck(:id)}. #{DateTime.now.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")}"
  end

  def self.make_trades(quote)
    scheme = Scheme.where(state: "active").first
    return unless scheme.present?
    strategy = Strategy.choose_highest_priority(quote.passing_strategies)
    return unless strategy.present?
    CoinbaseService.trade(strategy, quote)
  end

  def strategies(category=["buy", "sell"])
    Strategy.where(id: self.strategy_ids).where(category: category)
  end
end
