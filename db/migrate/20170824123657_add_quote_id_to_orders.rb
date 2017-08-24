class AddQuoteIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :quote_id, :integer
    add_column :orders, :strategy_id, :integer
    add_index :orders, :quote_id
    add_index :orders, :strategy_id
  end
end
