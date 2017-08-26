class Wallet < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :coins, -> { where(sold_at: nil) }

  def self.for_trading
    Wallet.find_by_name("trading")
  end
end
