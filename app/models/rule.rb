class Rule < ActiveRecord::Base
  belongs_to :strategy

  validates :strategy_id, presence: true
  validates :comparison_logic, presence: true

  scope :with_and_operator, -> { where(operator: "and") }
  scope :with_or_operator, -> { where(operator: "or") }

  COMPARISON_LOGICS = [
    "most_recent_quote",
    "quote_running_average",
    "wallet_empty",
    "wallet_has_coins",
    "wallet_has_two_coins",
    "last_coin_in_wallet",
    "first_coin_in_wallet",
    "no_recent_quote_with_same_strategy"
  ]

  def coins
    Wallet.for_trading.coins.send(self.strategy.currency.downcase)
  end

  def quote_is_passing?(quote)
    check_method = self.comparison_logic + "_passes_comparison_logic?"
    self.send(check_method, quote)
  end

  def wallet_empty_passes_comparison_logic?(quote)
    self.coins.empty?
  end

  def wallet_has_coins_passes_comparison_logic?(quote)
    self.coins.any?
  end

  def wallet_has_two_coins_passes_comparison_logic?(quote)
    self.coins.count == 2
  end

  def no_recent_quote_with_same_strategy_passes_comparison_logic?(quote)
    Quote.get_previous_quotes(quote, self.lookback_minutes).each do |q|
      return false if q.passing_strategy_ids.include?(self.strategy_id)
    end
    true
  end

  def quote_running_average_passes_comparison_logic?(quote)
    prices = Quote.get_previous_quotes(quote, self.lookback_minutes).pluck(:price)
    return false unless prices.any?
    self.percent_change_passes_threshold?(Numbers.percent_change(quote.price, Numbers.average(prices)))
  end

  def first_coin_in_wallet_passes_comparison_logic?(quote)
    coin = Coin.acquired_first(self.coins)
    return false unless coin.present?
    self.percent_change_passes_threshold?(Numbers.percent_change(quote.price, coin.acquired_price))
  end

  def last_coin_in_wallet_passes_comparison_logic?(quote)
    coin = Coin.acquired_last(self.coins)
    return false unless coin.present?
    self.percent_change_passes_threshold?(Numbers.percent_change(quote.price, coin.acquired_price))
  end

  def most_recent_quote_passes_comparison_logic?(quote)
    Quote.get_previous_quotes(quote, self.lookback_minutes).each do |q|
      return true if self.percent_change_passes_threshold?(Numbers.percent_change(quote.price, q.price))
    end
    false
  end

  def percent_change_passes_threshold?(percent_change)
    if self.percent_increase.present?
      percent_change >= self.percent_increase
    else
      percent_change = percent_change * (-1) unless percent_change.negative?
      percent_change <= self.percent_decrease
    end
  end
end
