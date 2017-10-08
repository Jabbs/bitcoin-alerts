class DropPoloniexQuoteTable < ActiveRecord::Migration
  def change
    drop_table :poloniex_quotes
  end
end
