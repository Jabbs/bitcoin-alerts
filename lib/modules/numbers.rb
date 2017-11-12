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

  def self.average(ary)
    ary.inject(:+).to_f / ary.size
  end

  def self.percent_from_total(total, percent)
    (percent.to_f/100.to_f)*total.to_f
  end

  def self.next_meaningful_amount(amount, dir="up")
    n = amount.to_s
    left_of_zero = n.split(".").first
    right_of_zero = n.include?(".") ? n.split(".").last : "0"

    if left_of_zero == "0"
      leading_zeros = 0
      right_of_zero.split("").each do |n|
        break if n != "0"
        leading_zeros += 1
      end
      right_of_zero.sub!(/^[0]+/,'') # removes leading zeros
      quantized_amt = ("1" + ("0" * (right_of_zero.length - 1))).to_f
      step = dir == "up" ? 1 : 0
      r = (right_of_zero.first(1).to_i + step) * quantized_amt
      w = r - (quantized_amt / 2).to_f
      if dir == "up"
        o = w > right_of_zero.to_f ? w : r
      else
        o = r < right_of_zero.to_f ? r : w
      end
      output = ("0." + ("0" * leading_zeros) + o.to_s.sub(".", "")).to_f
    elsif left_of_zero.length == 1
      if dir == "up"
        output = right_of_zero.first.to_i >= 5 ? (left_of_zero.to_i + 1) : (left_of_zero.to_i + 0.5)
      else
        output = right_of_zero.first.to_i <= 5 ? (left_of_zero.to_i) : (left_of_zero.to_i + 0.5)
      end
    else left_of_zero != "0"
      quantized_amt = ("1" + ("0" * (left_of_zero.length - 1))).to_f
      step = dir == "up" ? 1 : 0
      r = (left_of_zero.first(1).to_i + step) * quantized_amt
      w = r - (quantized_amt / 2).to_f
      if dir == "up"
        output = w > amount ? w : r
      else
        output = r < amount ? r : w
      end
    end
    output
  end
end
