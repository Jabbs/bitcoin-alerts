class Quote < ActiveRecord::Base
  validates :bid, presence: true
  validates :ask, presence: true
  validates :price, presence: true
  validates :size, presence: true
  validates :volume, presence: true
  validates :currency_pair, presence: true
  validates :trade_id, presence: true, uniqueness: true
  validates :traded_at, presence: true

  def self.get_previous_quotes(quote, lookback_minutes)
    Quote.where(currency_pair: quote.currency_pair).where("traded_at > ?", quote.traded_at - lookback_minutes.minutes).where("traded_at < ?", quote.traded_at).order("traded_at desc")
  end

  def self.recent_quotes(lookback_minutes=2)
    Quote.where("traded_at > ?", lookback_minutes.minutes.ago)
  end

  def self.most_recent_currency_prices(quote_id)
    h = {}
    h[:btc] = nil
    h[:eth] = nil
    h[:ltc] = nil
    10.times do
      q = Quote.find_by_id(quote_id)
      currency_sym = q.currency_pair.split("-")[0].downcase.to_sym
      h[currency_sym] = q.price
      return h if h[:btc].present? && h[:eth].present? && h[:ltc].present?
      quote_id -= 1
    end
    nil
  end

  def assign_passing_strategies(strategies)
    strategy_ids_that_pass = []
    strategies.where(currency_pair: self.currency_pair).each do |strategy|
      strategy_ids_that_pass << strategy.id if strategy.quote_is_passing?(self)
    end
    self.update_attribute(:passing_strategy_ids, strategy_ids_that_pass) if strategy_ids_that_pass.any?
  end

  def traded_at_with_pretty_cst_time
    self.traded_at.in_time_zone("Central Time (US & Canada)").strftime("%m/%d/%y:%-l:%M%P")
  end

  def passing_strategies
    Strategy.where(id: self.passing_strategy_ids)
  end
end
