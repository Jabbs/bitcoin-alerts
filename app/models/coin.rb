class Coin < ActiveRecord::Base
  validates :acquired_price, presence: true
  validates :currency, presence: true

  scope :btc, -> { where(currency: "btc") }
  scope :ltc, -> { where(currency: "ltc") }
  scope :eth, -> { where(currency: "eth") }
end
