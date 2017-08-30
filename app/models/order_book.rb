class OrderBook < ActiveRecord::Base
  has_many :order_book_items
end
