module Numbers
  def self.percent_change(amt, previous_amt, round=2)
    return 0.0 if previous_amt == 0 && amt == 0
    return -100.0 if previous_amt == 0 && amt < 0
    return 100.0 if previous_amt == 0 && amt > 0
    diff = amt.to_f - previous_amt.to_f
    n = (diff.abs / previous_amt.abs.to_f * 100)
    n = n * (-1) if diff < 0
    n.round(round)
  end

  def self.percent_from_total(total, percent)
    (percent.to_f/100.to_f)*total.to_f
  end
end
