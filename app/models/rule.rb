class Rule < ActiveRecord::Base
  belongs_to :strategy
  belongs_to :channel

  validates :operator, presence: true

  scope :with_and_operator, -> { where(operator: "and") }
  scope :with_or_operator, -> { where(operator: "or") }

  COMPARISON_LOGICS = [
    "most_recent_quote",
    "quote_running_average",
    "no_recent_quote_with_same_strategy"
  ]

  CUSTOM_FUNCTIONS = [
    "passed_meaningful_barrier_ceiling?",
    "passed_meaningful_barrier_floor?"
  ]

  def print_description
    text = " - "
    if self.comparison_logic == "most_recent_quote" || self.comparison_logic == "quote_running_average"
      text += self.percent_increase.present? ? "ceiling threshold: %" + self.percent_increase.to_s : "floor threshold: %" + self.percent_decrease.to_s
      text += ". Lookback #{(lookback_minutes.to_f/60.to_f).round(2)} hours"
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

  def generate_message
    paired_symbol = self.channel.currency.paired_symbol
    if self.custom_function.present? && self.custom_function == "passed_meaningful_barrier_ceiling?"
      ceiling = Numbers.next_meaningful_amount(self.comparison_value_ten_minutes_ago, "up")
      ceiling.present? ? Numbers.format_number_to_str_decimal(ceiling) + " " + paired_symbol : ""
    elsif self.custom_function.present? && self.custom_function == "passed_meaningful_barrier_floor?"
      floor = Numbers.next_meaningful_amount(self.comparison_value_ten_minutes_ago, "down")
      floor.present? ? Numbers.format_number_to_str_decimal(floor) + " " + paired_symbol : ""
    elsif self.percent_increase.present? || self.percent_decrease.present? || self.ceiling.present? || self.floor.present?
      comparison_value = self.comparison_value
      comparison_value.present? ? Numbers.format_number_to_str_decimal(comparison_value) + " " + paired_symbol : ""
    else
      ""
    end
  end

  def passed_meaningful_barrier_ceiling?
    ceiling = Numbers.next_meaningful_amount(self.comparison_value_ten_minutes_ago, "up")
    self.comparison_value > ceiling
  end

  def passed_meaningful_barrier_floor?
    floor = Numbers.next_meaningful_amount(self.comparison_value_ten_minutes_ago, "down")
    self.comparison_value < floor
  end

  def is_passing?
    if self.custom_function.present?
      self.send(self.custom_function)
    elsif self.percent_increase.present? || self.percent_decrease.present?
      self.percent_change_is_passing?
    elsif self.ceiling.present? || self.floor.present?
      self.ceiling_or_floor_is_passing?
    else
      false
    end
  end

  def ceiling_or_floor_is_passing?
    if self.ceiling.present?
      self.comparison_value > self.ceiling
    elsif self.floor.present?
      self.comparison_value < self.floor
    end
  end

  def percent_change_is_passing?
    if self.comparison_table_scope_method.present? && self.comparison_table_scope_value.present?
      average = self.comparison_class.where(self.comparison_table_scope_method => self.comparison_table_scope_value)
                .where("created_at > ?", DateTime.now - self.lookback_minutes.minutes)
                .average(self.comparison_table_column)
    else
      average = self.comparison_class.where("created_at > ?", DateTime.now - self.lookback_minutes.minutes).average(self.comparison_table_column)
    end
    return false unless average.present?
    comparison = self.comparison_value
    return false unless comparison.present?
    self.percent_change_passes_threshold?(Numbers.percent_change(comparison, average))
  end

  def comparison_class
    self.comparison_table.singularize.classify.constantize
  end

  def comparison_value
    if self.comparison_table_scope_method.present? && self.comparison_table_scope_value.present?
      self.comparison_class.where(self.comparison_table_scope_method => self.comparison_table_scope_value)
        .where("created_at > ?", 5.minutes.ago).order(:id).try(:last).try(:send, self.comparison_table_column)
    else
      self.comparison_class.where("created_at > ?", 5.minutes.ago).order(:id).try(:last).try(:send, self.comparison_table_column)
    end
  end

  def comparison_value_ten_minutes_ago
    if self.comparison_table_scope_method.present? && self.comparison_table_scope_value.present?
      self.comparison_class.where(self.comparison_table_scope_method => self.comparison_table_scope_value)
        .where("created_at > ?", 15.minutes.ago).where("created_at < ?", 10.minutes.ago)
        .order(:id).try(:last).try(:send, self.comparison_table_column)
    else
      self.comparison_class
        .where("created_at > ?", 15.minutes.ago).where("created_at < ?", 10.minutes.ago)
        .order(:id).try(:last).try(:send, self.comparison_table_column)
    end
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

  def most_recent_quote_passes_comparison_logic?(quote)
    Quote.get_previous_quotes(quote, self.lookback_minutes).each do |q|
      return true if self.percent_change_passes_threshold?(Numbers.percent_change(quote.price, q.price))
    end
    false
  end
end
