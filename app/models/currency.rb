class Currency < ActiveRecord::Base
  scope :with_bittrex_data, -> { where(symbol: BittrexMarketSummary::SELECTED_MARKETS.map { |m| m.split("-").last }.uniq) }

  def selected_market_name
    BittrexMarketSummary::SELECTED_MARKETS.select { |m| m.include?("-" + self.symbol) }.try(:first)
  end
end
