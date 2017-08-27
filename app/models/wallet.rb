class Wallet < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :coins, -> { where(sold_at: nil) }

  def self.for_trading
    Wallet.find_by_name("trading")
  end

  def self.pretty_breakdown
    text = ""
    ["btc", "ltc", "eth"].each do |currency|
      coins = Wallet.for_trading.coins.send(currency)
      text << "#{currency.upcase} coins "
    end
    text
  end
end
