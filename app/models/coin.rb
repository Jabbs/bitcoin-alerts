class Coin < ActiveRecord::Base
  belongs_to :order

  validates :acquired_price, presence: true
  validates :currency, presence: true

  scope :btc, -> { where(currency: "btc") }
  scope :ltc, -> { where(currency: "ltc") }
  scope :eth, -> { where(currency: "eth") }

  def self.acquired_first(coins)
    coins.order(:created_at).try(:first)
  end

  def self.acquired_last(coins)
    coins.order(:created_at).try(:last)
  end
end
