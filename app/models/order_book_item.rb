class OrderBookItem < ActiveRecord::Base
  belongs_to :order_book

  scope :buy, -> { where(side: "buy") }
  scope :sell, -> { where(side: "sell") }
end
