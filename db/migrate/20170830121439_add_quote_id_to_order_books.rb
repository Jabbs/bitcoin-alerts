class AddQuoteIdToOrderBooks < ActiveRecord::Migration
  def change
    add_column :order_books, :quote_id, :integer
    add_index :order_books, :quote_id
  end
end
