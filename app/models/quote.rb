class Quote < ActiveRecord::Base
  validates :bid, presence: true
  validates :ask, presence: true
  validates :price, presence: true
  validates :size, presence: true
  validates :volume, presence: true
  validates :currency_pair, presence: true
  validates :trade_id, presence: true, uniqueness: true
  validates :traded_at, presence: true

  def self.get_previous_quotes(quote, lookback_hours)
    Quote.where(currency_pair: quote.currency_pair).where("traded_at > ?", quote.traded_at - lookback_hours.hours).where("traded_at < ?", quote.traded_at).order("traded_at desc")
  end

  def self.recent_quotes(lookback_minutes=2)
    Quote.where("traded_at > ?", lookback_minutes.minutes.ago)
  end

  def self.check_for_passing_strategies(quotes)
    quotes.each do |quote|
      quote.check_and_update_passing_strategy_ids(Strategy.all)
      quote.reload.process_strategies
    end
  end

  def process_strategies
    return unless self.passing_strategy_ids.any?
    Strategy.where(id: self.passing_strategy_ids).each do |strategy|
      strategy.send_slack_message(self)
    end
  end

  def check_and_update_passing_strategy_ids(strategies)
    strategy_ids_that_pass = []
    strategies.each do |strategy|
      strategy_ids_that_pass << strategy.id if strategy.quote_is_passing?(self)
    end
    self.update_attribute(:passing_strategy_ids, strategy_ids_that_pass) if strategy_ids_that_pass.any?
  end

  def pretty_cst_time
    self.traded_at.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")
  end
end
