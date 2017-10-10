class Currency < ActiveRecord::Base
  scope :with_bittrex_data, -> { where(symbol: BittrexMarketSummary::SELECTED_MARKETS.map { |m| m.split("-").last }.uniq) }
end
