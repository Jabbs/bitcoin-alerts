class CreateBittrexMarketSummaries < ActiveRecord::Migration
  def change
    create_table :bittrex_market_summaries do |t|
      t.string :market_name
      t.decimal :high, precision: 25, scale: 10
      t.decimal :low, precision: 25, scale: 10
      t.decimal :volume, precision: 25, scale: 10
      t.decimal :last, precision: 25, scale: 10
      t.decimal :base_volume, precision: 25, scale: 10
      t.datetime :time_stamp
      t.decimal :bid, precision: 25, scale: 10
      t.decimal :ask, precision: 25, scale: 10
      t.integer :open_buy_orders
      t.integer :open_sell_orders
      t.decimal :prev_day, precision: 25, scale: 10
      t.datetime :created

      t.timestamps null: false
    end
    add_index :bittrex_market_summaries, :market_name
    add_index :bittrex_market_summaries, :created_at
  end
end
