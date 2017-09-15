class BittrexMarketSummary < ActiveRecord::Base
  validates :market_name, presence: true
end
