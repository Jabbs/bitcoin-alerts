class Quote < ActiveRecord::Base
  validates :bid, presence: true
  validates :ask, presence: true
  validates :price, presence: true
  validates :size, presence: true
  validates :volume, presence: true
  validates :currency_pair, presence: true
  validates :trade_id, presence: true
  validates :traded_at, presence: true

  has_one :order_book
  has_many :trades
  has_many :slack_notifications

  def self.income_estimate(price=8500, interest=0.075, cycles=10, days_per_cycle=150)
    d = Date.today
    bank = 0
    btc = 10.127
    puts "-----------------------------------------------------------"
    puts "#{interest * 100}% INTEREST, #{days_per_cycle} DAYS PER DOUBLING:"
    puts "-----------------------------------------------------------"
    cycles.times do
      d = d + days_per_cycle.days
      price = price * 2
      bank = bank + (interest*btc*price)
      btc = btc - (interest*btc)
      puts d.strftime("%m/%d/%Y") + " (" + "Bank: $" + bank.round(2).to_s + ", " + "Price: $" + price.round(2).to_s + ", " + "BTC: " + btc.round(8).to_s + ")"
    end
    puts "-----------------------------------------------------------"
  end

  def self.average_price_per_hour
    ActiveRecord::Base.logger.level = 1
    first_quote = Quote.where("traded_at >= ?", 8.days.ago).where(currency_pair: "LTC-USD").order("traded_at asc").first
    hour = first_quote.traded_at.hour
    quote_count = 0
    price_sum = 0
    Quote.where("traded_at >= ?", 8.days.ago).where(currency_pair: "LTC-USD").order("traded_at asc").each do |q|
      if q.traded_at.hour == hour
        quote_count += 1
        price_sum += q.price
      else
        puts "Day: #{q.traded_at.in_time_zone("Central Time (US & Canada)").strftime("%m/%d")}" if hour == 0
        puts "Hour #{hour}: #{(price_sum.to_f/quote_count.to_f).round(2)}"
        quote_count = 0
        price_sum = 0
        hour == 23 ? hour = 0 : hour += 1
      end
    end
    return true
  end

  def self.five_minute_interval_analysis(currency_pair="BTC-USD", start_time="29-8-2017".to_datetime.in_time_zone("Central Time (US & Canada)").beginning_of_day, end_time=DateTime.now.in_time_zone("Central Time (US & Canada)").beginning_of_day)
    # starts at 12:00AM CST
    # end_time = "11-9-2017".to_datetime.in_time_zone("Central Time (US & Canada)").beginning_of_day
    avgs = []
    288.times do
      avg = Quote.time_analysis_avg(start_time, end_time, currency_pair)
      puts start_time.strftime("%-l:%M%P")
      puts avg.round(2)
      puts "-------------------"
      avgs << avg.round(2)
      start_time = start_time + 5.minutes
    end
    avgs
  end

  def self.time_analysis_avg(start_time, end_time, currency_pair="BTC-USD", running_price_average_lookback_hrs=6)
    percent_changes = []
    ((end_time - start_time)/24/60/60 - 1.to_f).to_i.times do
      quote = Quote.where(currency_pair: currency_pair).where("traded_at >= ?", start_time).order("traded_at asc").first
      running_price_average = quote.running_price_average(running_price_average_lookback_hrs*60)
      percent_change = Numbers.percent_change(quote.price, running_price_average)
      percent_changes << percent_change
      # puts percent_change.to_s + " (#{time.strftime("%m/%d")})"
      start_time = start_time + 24.hours
    end
    Numbers.average(percent_changes)
  end

  def self.get_previous_quotes(quote, lookback_minutes)
    Quote.where(currency_pair: quote.currency_pair).where("traded_at > ?", quote.traded_at - lookback_minutes.minutes).where("traded_at < ?", quote.traded_at).order("traded_at desc")
  end

  def self.recent_quotes
    Quote.where("traded_at > ?", 1.minute.ago)
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

  def running_price_average(lookback_minutes, lookforward_minutes=nil)
    if lookforward_minutes.present?
      Numbers.average(Quote.where(currency_pair: self.currency_pair).where("traded_at > ?", self.traded_at - lookback_minutes.minutes).where("traded_at <= ?", self.traded_at + lookforward_minutes.minutes).pluck(:price))
    else
      Numbers.average(Quote.where(currency_pair: self.currency_pair).where("traded_at > ?", self.traded_at - lookback_minutes.minutes).where("traded_at <= ?", self.traded_at).pluck(:price))
    end
  end

  def assign_passing_strategies(strategies)
    strategy_ids_that_pass = []
    strategies.where(currency_pair: self.currency_pair).each do |strategy|
      strategy_ids_that_pass << strategy.id if strategy.quote_is_passing?(self)
    end
    self.update_attribute(:passing_strategy_ids, strategy_ids_that_pass) if strategy_ids_that_pass.any?
  end

  def traded_at_with_pretty_cst_time
    self.traded_at.in_time_zone("Central Time (US & Canada)").strftime("%m/%d:%-l:%M%P")
  end

  def passing_strategies
    Strategy.where(id: self.passing_strategy_ids)
  end
end
