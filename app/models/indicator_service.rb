class IndicatorService < ActiveRecord::Base

  INTERVALS = {
    "1h " => 1.hour,
    "4h " => 4.hours,
    "6h " => 6.hours,
    "12h" => 12.hours,
    "1d " => 1.day,
    "1w " => 1.week
  }

  def self.candle_is_eight_or_nine?(candle)
    candle.present? && candle[2].present? && (candle[2] == 8 || candle[2] == 9)
  end

  def self.send_slack_messages(ending_time=Time.zone.now)
    CoinbaseService::CURRENCY_PAIRS.each do |currency_pair|
      info = []
      info << currency_pair + "\n"
      send_notification = false
      IndicatorService::INTERVALS.each do |k, v|
        candle = IndicatorService.td_candles(ending_time, currency_pair, v).last
        send_notification = true if IndicatorService.candle_is_eight_or_nine?(candle)
        info << IndicatorService.print_td_candle_info(candle, " " + k) + "\n" unless v == 1.week && !send_notification # skip the 1w if no notifications for the others
      end
      SlackService.send_slack_notification(info.join, "td-indicator") if send_notification
    end
  end

  def self.print_td_currencies(ending_time=Time.zone.now)
    puts "------------------------------------"
    CoinbaseService::CURRENCY_PAIRS.each do |currency_pair|
      IndicatorService.print_td_candle_infos(ending_time, currency_pair)
    end
    puts "------------------------------------"
  end

  def self.print_td_candle_infos(ending_time, currency_pair="BTC-USD")
    puts "------------------------------------"
    puts currency_pair
    IndicatorService::INTERVALS.each do |k, v|
      candle = IndicatorService.td_candles(ending_time, currency_pair, v).last
      puts IndicatorService.print_td_candle_info(candle, " " + k)
    end
  end

  def self.print_td_candle_info(candle, prefix="")
    return "MISSING" unless candle.present?
    time = candle[3].in_time_zone("Central Time (US & Canada)").strftime("%m/%d:%-l:%M%P")
    close = candle[0].to_f.round(2).to_s
    close = close.split(".").last.size == 1 ? close + "0" : close
    if candle[1].present? && candle[2].present?
      color = candle[1].upcase
      count = candle[2].to_s
      spacing = color == "GREEN" ? " " : "   "
      message = color + spacing + count + " (" + time + " " + close + ")"
      if (color == "RED" && count == "8") || (color == "RED" && count == "9")
        message = message + " ***BUY"
      elsif (color == "GREEN" && count == "8") || (color == "GREEN" && count == "9")
        message = message + " ***SELL"
      end
    else
      message = "MISSING" + " (" + time + " " + close + ")"
    end
    if prefix
      prefix + " | " + message
    else
      message
    end
  end

  def self.td_candles(ending_time, currency_pair="BTC-USD", interval=1.day, steps=25)
    ActiveRecord::Base.logger.level = 1
    steps = 50 if interval == 1.hour || interval == 1.hours
    initial_time = ending_time.to_time.in_time_zone.end_of_day
    initial_time = ending_time.to_time.in_time_zone.end_of_week if interval == 1.week
    initial_time = ending_time.to_time.in_time_zone.end_of_month if interval == 1.month
    current_time = initial_time - (steps*interval)
    current_time = current_time.end_of_month if interval == 1.month
    log = []
    closes = []
    count = 0
    color = nil
    steps.times do
      # puts current_time
      quote = Quote.where(currency_pair: currency_pair).where("created_at > ?", current_time - 3.minutes).where("created_at < ?", current_time).last
      close = quote.try(:price)
      # puts close.to_s
      if closes.size == 4
        comparison = closes.shift
        # puts "compared to: #{comparison.to_s}"
        if comparison && close && close < comparison
          count = 0 if color != "red" || count == 9
          count += 1
          color = "red"
        elsif comparison && close && close > comparison
          count = 0 if color != "green" || count == 9
          count += 1
          color = "green"
        end
      end
      # puts color + " " + count.to_s if count && color
      # puts "----"
      closes << close
      log << [close.to_s, color, count, quote.try(:created_at)] if close.present?
      current_time += interval
    end
    log
  end


end
