class Rule < ActiveRecord::Base
  belongs_to :strategy

  validates :strategy_id, presence: true
  validates :operator, presence: true
  validates :comparison_logic, presence: true

  scope :with_and_operator, -> { where(operator: "and") }
  scope :with_or_operator, -> { where(operator: "or") }

  COMPARISON_LOGICS = [
    "most_recent_quote",
    "quote_running_average",
    "last_coin_in_wallet",
    "first_coin_in_wallet",
    "wallet_empty",
    "wallet_has_coins",
    "wallet_has_one_coin",
    "wallet_has_one_or_less_coins",
    "wallet_has_two_coins",
    "no_recent_quote_with_same_strategy",
    "wallet_not_full"
  ]

  def print_description
    text = " - "
    if self.comparison_logic == "most_recent_quote" || self.comparison_logic == "quote_running_average"
      text += self.percent_increase.present? ? "ceiling threshold: %" + self.percent_increase.to_s : "floor threshold: %" + self.percent_decrease.to_s
      text += ". Lookback #{(lookback_minutes.to_f/60.to_f).round(2)} hours"
    elsif self.comparison_logic == "first_coin_in_wallet" || self.comparison_logic == "last_coin_in_wallet"
      text += self.percent_increase.present? ? "ceiling threshold: %" + self.percent_increase.to_s : "floor threshold: %" + self.percent_decrease.to_s
    else
      text = ""
    end
    puts "##{self.id} | #{self.operator.upcase} | #{self.comparison_logic}" + text
  end

  def coins
    Wallet.for_trading.coins.send(self.strategy.currency.downcase)
  end

  def quote_is_passing?(quote)
    check_method = self.comparison_logic + "_passes_comparison_logic?"
    self.send(check_method, quote)
  end

  def wallet_not_full_passes_comparison_logic?(quote)
    self.strategy.wallet_not_full?
  end

  def wallet_empty_passes_comparison_logic?(quote)
    self.coins.empty?
  end

  def wallet_has_coins_passes_comparison_logic?(quote)
    self.coins.any?
  end

  def wallet_has_one_or_less_coins_passes_comparison_logic?(quote)
    self.coins.count <= 1
  end

  def wallet_has_one_coin_passes_comparison_logic?(quote)
    self.coins.count == 1
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
      percent_decrease = self.percent_decrease
      percent_decrease = percent_decrease * (-1) unless percent_decrease.negative?
      percent_change <= percent_decrease
    end
  end
end
