class AddEthPriceToQuotes < ActiveRecord::Migration
  def change
    add_column :poloniex_quotes, :eth_price, :decimal, precision: 25, scale: 10
    add_column :bittrex_market_summaries, :eth_price, :decimal, precision: 25, scale: 10
  end
end
