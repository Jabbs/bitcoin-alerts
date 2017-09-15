class DropTradesAndOrderBooks < ActiveRecord::Migration
  def change
    drop_table :trades
    drop_table :order_book_items
    drop_table :order_books
  end
end
