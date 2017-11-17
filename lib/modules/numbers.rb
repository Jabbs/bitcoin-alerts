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

  def self.format_number_to_str_decimal(amt)
    amt_string = BigDecimal.new(amt, 10).to_s
    amt_string.split(".0").size == 1 ? amt_string.sub(".0", "") : amt_string
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
      w1 = r - (quantized_amt / 2).to_f
      w2 = r + (quantized_amt / 2).to_f
      if dir == "up"
        o = [r,w1,w2].sort.find { |x| x > right_of_zero.to_f }
      else
        o = [r,w1,w2].sort.reverse.find { |x| x < right_of_zero.to_f }
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
      w1 = r - (quantized_amt / 2).to_f
      w2 = r + (quantized_amt / 2).to_f
      if dir == "up"
        output = [r,w1,w2].sort.find { |x| x > amount }
      else
        output = [r,w1,w2].sort.reverse.find { |x| x < amount }
      end
    end
    output
  end
end
