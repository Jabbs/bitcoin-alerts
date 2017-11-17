class BittrexMarketSummary < ActiveRecord::Base
  validates :market_name, presence: true

  MARKETS = ["BTC-DOGE", "BTC-LTC", "BTC-FTC", "BTC-VTC", "BTC-PPC", "BTC-RDD", "BTC-NXT", "BTC-POT", "BTC-DASH", "BTC-BLK", "BTC-XMY", "BTC-AUR", "BTC-EFL", "BTC-GLD", "BTC-SLR", "BTC-PTC", "BTC-GRS", "BTC-NLG", "BTC-RBY", "BTC-XWC", "BTC-MONA", "BTC-THC", "BTC-ENRG", "BTC-ERC", "BTC-VRC", "BTC-CURE", "BTC-XMR", "BTC-CLOAK", "BTC-START", "BTC-KORE", "BTC-XDN", "BTC-TRUST", "BTC-NAV", "BTC-XST", "BTC-BTCD", "BTC-VIA", "BTC-UNO", "BTC-PINK", "BTC-IOC", "BTC-CANN", "BTC-SYS", "BTC-NEOS", "BTC-DGB", "BTC-BURST", "BTC-EXCL", "BTC-SWIFT", "BTC-DOPE", "BTC-BLOCK", "BTC-ABY", "BTC-BYC", "BTC-XMG", "BTC-BLITZ", "BTC-BAY", "BTC-BTS", "BTC-FAIR", "BTC-SPR", "BTC-VTR", "BTC-XRP", "BTC-EMC2", "BTC-COVAL", "BTC-NXS", "BTC-XCP", "BTC-BITB", "BTC-GEO", "BTC-FLDC", "BTC-GRC", "BTC-FLO", "BTC-NBT", "BTC-GAME", "BTC-MUE", "BTC-XEM", "BTC-CLAM", "BTC-DMD", "BTC-GAM", "BTC-SPHR", "BTC-OK", "BTC-SNRG", "BTC-PKB", "BTC-CPC", "BTC-AEON", "BTC-ETH", "BTC-GCR", "BTC-TX", "BTC-BCY", "BTC-EXP", "BTC-INFX", "BTC-OMNI", "BTC-AMP", "BTC-AGRS", "BTC-XLM", "BTC-BTA", "USDT-BTC", "BTC-CLUB", "BTC-VOX", "BTC-EMC", "BTC-FCT", "BTC-MAID", "BTC-EGC", "BTC-SLS", "BTC-RADS", "BTC-DCR", "BTC-SAFEX", "BTC-BSD", "BTC-XVG", "BTC-PIVX", "BTC-XVC", "BTC-MEME", "BTC-STEEM", "BTC-2GIVE", "BTC-LSK", "BTC-PDC", "BTC-BRK", "BTC-DGD", "ETH-DGD", "BTC-WAVES", "BTC-RISE", "BTC-LBC", "BTC-SBD", "BTC-BRX", "BTC-DRACO", "BTC-ETC", "ETH-ETC", "BTC-STRAT", "BTC-UNB", "BTC-SYNX", "BTC-TRIG", "BTC-EBST", "BTC-VRM", "BTC-SEQ", "BTC-XAUR", "BTC-SNGLS", "BTC-REP", "BTC-SHIFT", "BTC-ARDR", "BTC-XZC", "BTC-NEO", "BTC-ZEC", "BTC-ZCL", "BTC-IOP", "BTC-DAR", "BTC-GOLOS", "BTC-UBQ", "BTC-KMD", "BTC-GBG", "BTC-SIB", "BTC-ION", "BTC-LMC", "BTC-QWARK", "BTC-CRW", "BTC-SWT", "BTC-TIME", "BTC-MLN", "BTC-ARK", "BTC-DYN", "BTC-TKS", "BTC-MUSIC", "BTC-DTB", "BTC-INCNT", "BTC-GBYTE", "BTC-GNT", "BTC-NXC", "BTC-EDG", "BTC-LGD", "BTC-TRST", "ETH-GNT", "ETH-REP", "USDT-ETH", "ETH-WINGS", "BTC-WINGS", "BTC-RLC", "BTC-GNO", "BTC-GUP", "BTC-LUN", "ETH-GUP", "ETH-RLC", "ETH-LUN", "ETH-SNGLS", "ETH-GNO", "BTC-APX", "BTC-TKN", "ETH-TKN", "BTC-HMQ", "ETH-HMQ", "BTC-ANT", "ETH-TRST", "ETH-ANT", "BTC-SC", "ETH-BAT", "BTC-BAT", "BTC-ZEN", "BTC-1ST", "BTC-QRL", "ETH-1ST", "ETH-QRL", "BTC-CRB", "ETH-CRB", "ETH-LGD", "BTC-PTOY", "ETH-PTOY", "BTC-MYST", "ETH-MYST", "BTC-CFI", "ETH-CFI", "BTC-BNT", "ETH-BNT", "BTC-NMR", "ETH-NMR", "ETH-TIME", "ETH-LTC", "ETH-XRP", "BTC-SNT", "ETH-SNT", "BTC-DCT", "BTC-XEL", "BTC-MCO", "ETH-MCO", "BTC-ADT", "ETH-ADT", "BTC-FUN", "ETH-FUN", "BTC-PAY", "ETH-PAY", "BTC-MTL", "ETH-MTL", "ETH-STORJ", "BTC-STORJ", "BTC-ADX", "ETH-ADX", "ETH-DASH", "ETH-SC", "ETH-ZEC", "USDT-ZEC", "USDT-LTC", "USDT-ETC", "USDT-XRP", "BTC-OMG", "ETH-OMG", "BTC-CVC", "ETH-CVC", "BTC-PART", "ETH-QTUM", "BTC-QTUM", "ETH-XMR", "ETH-XEM", "ETH-XLM", "ETH-NEO", "USDT-XMR", "USDT-DASH", "ETH-BCC", "USDT-BCC", "BTC-BCC", "USDT-NEO", "ETH-WAVES", "ETH-STRAT", "ETH-DGB", "ETH-BTS", "ETH-FCT", "USDT-OMG"]

  REMOVING_MARKETS = ["BTC-FTC", "BTC-PPC", "BTC-POT", "BTC-BLK", "BTC-XMY", "BTC-AUR", "BTC-EFL", "BTC-GLD", "BTC-SLR", "BTC-PTC", "BTC-NLG", "BTC-RBY", "BTC-XWC", "BTC-MONA", "BTC-THC", "BTC-ENRG", "BTC-VRC", "BTC-CURE", "BTC-XDN", "BTC-TRUST", "BTC-NAV", "BTC-XST", "BTC-BTCD", "BTC-VIA", "BTC-UNO", "BTC-PINK", "BTC-CANN", "BTC-BURST", "BTC-EXCL", "BTC-SWIFT", "BTC-DOPE", "BTC-BLOCK", "BTC-ABY", "BTC-BYC", "BTC-XMG", "BTC-BLITZ", "BTC-BAY", "BTC-FAIR", "BTC-SPR", "BTC-VTR", "BTC-EMC2", "BTC-COVAL", "BTC-NXS", "BTC-XCP", "BTC-BITB", "BTC-GEO", "BTC-FLDC", "BTC-GRC", "BTC-FLO", "BTC-NBT", "BTC-MUE", "BTC-GAM", "BTC-SPHR", "BTC-PKB", "BTC-CPC", "BTC-AEON", "BTC-GCR", "BTC-TX", "BTC-BCY", "BTC-EXP", "BTC-INFX", "BTC-OMNI", "BTC-AMP", "BTC-AGRS", "BTC-XLM", "BTC-BTA", "BTC-CLUB", "BTC-VOX", "BTC-EMC", "BTC-EGC", "BTC-SLS", "BTC-RADS", "BTC-SAFEX", "BTC-BSD", "BTC-XVC", "BTC-MEME", "BTC-2GIVE", "BTC-LSK", "BTC-PDC", "BTC-BRK", "BTC-DGD", "BTC-SBD", "BTC-BRX", "BTC-DRACO", "BTC-UNB", "BTC-SYNX", "BTC-EBST", "BTC-VRM", "BTC-SEQ", "BTC-XAUR", "BTC-SNGLS", "BTC-SHIFT", "BTC-XZC", "BTC-ZCL", "BTC-IOP", "BTC-DAR", "BTC-GOLOS", "BTC-GBG", "BTC-SIB", "BTC-ION", "BTC-LMC", "BTC-QWARK", "BTC-CRW", "BTC-SWT", "BTC-TIME", "BTC-MLN", "BTC-ARK", "BTC-DYN", "BTC-TKS", "BTC-MUSIC", "BTC-DTB", "BTC-INCNT", "BTC-GBYTE", "BTC-NXC", "BTC-EDG", "BTC-LGD", "BTC-TRST", "ETH-WINGS", "BTC-WINGS", "BTC-RLC", "BTC-GNO", "BTC-GUP", "BTC-LUN", "ETH-GUP", "ETH-RLC", "ETH-LUN", "ETH-SNGLS", "BTC-APX", "BTC-TKN", "ETH-TKN", "BTC-HMQ", "ETH-HMQ", "BTC-ANT", "ETH-TRST", "ETH-ANT", "BTC-SC", "BTC-ZEN", "BTC-1ST", "BTC-QRL", "ETH-1ST", "ETH-QRL", "BTC-CRB", "ETH-CRB", "ETH-LGD", "BTC-PTOY", "ETH-PTOY", "BTC-MYST", "ETH-MYST", "BTC-CFI", "ETH-CFI", "BTC-BNT", "ETH-BNT", "BTC-NMR", "ETH-NMR", "ETH-TIME", "BTC-SNT", "ETH-SNT", "BTC-DCT", "BTC-XEL", "BTC-ADT", "ETH-ADT", "BTC-FUN", "ETH-FUN", "BTC-PAY", "ETH-PAY", "BTC-MTL", "ETH-MTL", "ETH-STORJ", "BTC-STORJ", "BTC-ADX", "ETH-ADX", "ETH-SC", "BTC-CVC", "ETH-CVC", "BTC-PART", "ETH-QTUM", "BTC-QTUM", "ETH-XLM"]

  SELECTED_MARKETS = ["BTC-DOGE", "BTC-LTC", "BTC-VTC", "BTC-RDD", "BTC-NXT", "BTC-DASH", "BTC-GRS", "BTC-ERC", "BTC-XMR", "BTC-CLOAK", "BTC-START", "BTC-KORE", "BTC-IOC", "BTC-SYS", "BTC-NEOS", "BTC-DGB", "BTC-BTS", "BTC-XRP", "BTC-GAME", "BTC-XEM", "BTC-CLAM", "BTC-DMD", "BTC-OK", "BTC-SNRG", "BTC-ETH", "USDT-BTC", "BTC-FCT", "BTC-MAID", "BTC-DCR", "BTC-XVG", "BTC-PIVX", "BTC-STEEM", "ETH-DGD", "BTC-WAVES", "BTC-RISE", "BTC-LBC", "BTC-ETC", "ETH-ETC", "BTC-STRAT", "BTC-TRIG", "BTC-REP", "BTC-ARDR", "BTC-NEO", "BTC-ZEC", "BTC-UBQ", "BTC-KMD", "BTC-GNT", "ETH-GNT", "ETH-REP", "USDT-ETH", "ETH-GNO", "ETH-BAT", "BTC-BAT", "ETH-LTC", "ETH-XRP", "BTC-MCO", "ETH-MCO", "ETH-DASH", "ETH-ZEC", "USDT-ZEC", "USDT-LTC", "USDT-ETC", "USDT-XRP", "BTC-OMG", "ETH-OMG", "ETH-XMR", "ETH-XEM", "ETH-NEO", "USDT-XMR", "USDT-DASH", "ETH-BCC", "USDT-BCC", "BTC-BCC", "USDT-NEO", "ETH-WAVES", "ETH-STRAT", "ETH-DGB", "ETH-BTS", "ETH-FCT", "USDT-OMG"]

  def self.print_daily_avgs(days=50, market_name="USDT-BTC")
    ActiveRecord::Base.logger.level = 1
    date = BittrexMarketSummary.first.created_at
    last_avg = nil
    percent_change = ""
    days.times do
      avg = BittrexMarketSummary.where(market_name: market_name).where("created_at > ?", date.beginning_of_day).where("created_at < ?", date.end_of_day).average(:last)
      percent_change = Numbers.percent_change(avg, last_avg).round(1).to_s if last_avg
      puts avg.round(2).to_s + " (#{percent_change}%)" + " " + date.strftime("%m/%d/%y")
      date = date + 1.day
      last_avg = avg
    end
  end

  def self.daily_info(date, lookback_days=7, market_name="USDT-BTC")
    ActiveRecord::Base.logger.level = 1
    data = []
    lookback_days.times do
      yesterdays_bms = BittrexMarketSummary.where(market_name: market_name).where("created_at < ?", date.beginning_of_day.yesterday + 5.minutes).where("created_at > ?", date.beginning_of_day.yesterday).order(:id).first
      todays_bms = BittrexMarketSummary.where(market_name: market_name).where("created_at < ?", date.beginning_of_day + 5.minutes).where("created_at > ?", date.beginning_of_day).order(:id).first
      info = {}
      info[:date] = date.yesterday.to_date
      info[:open] = yesterdays_bms.try(:last)
      info[:close] = todays_bms.try(:last)
      info[:high] = todays_bms.try(:high)
      info[:low] = todays_bms.try(:low)
      info[:volume] = todays_bms.try(:volume)
      data << OpenStruct.new(info)
      date = date + 1.day
    end
    data
  end

  def self.average_volume(market_name="USDT-BTC", days=30)
    BittrexMarketSummary.where(market_name: market_name).where("created_at > ?", days.days.ago).average(:volume)
  end

  def recent_btc_price
    BittrexMarketSummary.where(market_name: "USDT-BTC").where("created_at < ?", self.created_at).where("created_at > ?", self.created_at - 2.minutes).first.try(:last)
  end

  def running_price_average(lookback_minutes, lookforward_minutes=nil)
    if lookforward_minutes.present?
      Numbers.average(BittrexMarketSummary.where(market_name: self.market_name).where("created_at > ?", self.created_at - lookback_minutes.minutes).where("created_at <= ?", self.created_at + lookforward_minutes.minutes).pluck(:last))
    else
      Numbers.average(BittrexMarketSummary.where(market_name: self.market_name).where("created_at > ?", self.created_at - lookback_minutes.minutes).where("created_at <= ?", self.created_at).pluck(:last))
    end
  end

  def percent_change(minutes_ago)
    Numbers.percent_change(self.last, self.running_price_average(minutes_ago))
  end
end
