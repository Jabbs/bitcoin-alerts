class AddIndexingToOrderbook < ActiveRecord::Migration
  def change
    add_index :order_book_items, :order_book_id
    add_index :order_books, :created_at
  end
end
