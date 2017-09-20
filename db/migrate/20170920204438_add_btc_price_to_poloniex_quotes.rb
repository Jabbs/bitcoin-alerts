class AddBtcPriceToPoloniexQuotes < ActiveRecord::Migration
  def change
    add_column :poloniex_quotes, :btc_price, :decimal, precision: 25, scale: 10
    add_column :bittrex_market_summaries, :btc_price, :decimal, precision: 25, scale: 10
  end
end
