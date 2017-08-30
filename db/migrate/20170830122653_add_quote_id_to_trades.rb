class AddQuoteIdToTrades < ActiveRecord::Migration
  def change
    add_column :trades, :quote_id, :integer
    add_index :trades, :quote_id
  end
end
