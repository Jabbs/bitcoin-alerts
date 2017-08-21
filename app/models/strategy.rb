class Strategy < ActiveRecord::Base

  def check_for_message(quote)
    current_amt = quote.ask
    Quote.where("traded_at > ?", quote.created_at - self.lookback_hours.hours).where("traded_at < ?", quote.created_at).order("traded_at desc").each do |q|
      previous_amt = q.ask
      percent_change = Numbers.percent_change(current_amt, previous_amt)
      strategy_percent_change = self.percent_change_direction == "decrease" ? self.percent_change * (-1) : self.percent_change
      if percent_change <= strategy_percent_change
        return "#{self.slack_name}\n   *#{percent_change}%*   ($#{previous_amt.round(2)} -> $#{current_amt.round(2)})   |   #{q.pretty_cst_time} -> #{self.pretty_cst_time}"
      end
    end
    ""
  end

  def slack_name
    "_#{self.percent_change}% THRESHOLD HIT (LOOKING BACK #{self.lookback_hours} HOURS)_"
  end
end
