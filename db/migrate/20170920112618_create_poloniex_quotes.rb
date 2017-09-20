class CreatePoloniexQuotes < ActiveRecord::Migration
  def change
    create_table :poloniex_quotes do |t|
      t.decimal :last, precision: 25, scale: 10
      t.decimal :lowest_ask, precision: 25, scale: 10
      t.decimal :highest_bid, precision: 25, scale: 10
      t.decimal :percent_change, precision: 25, scale: 10
      t.decimal :base_volume, precision: 25, scale: 10
      t.decimal :quote_volume, precision: 25, scale: 10
      t.boolean :is_frozen
      t.decimal :high24hr, precision: 25, scale: 10
      t.decimal :low24hr, precision: 25, scale: 10
      t.string :currency_pair

      t.timestamps null: false
    end
    add_index :poloniex_quotes, :created_at
    add_index :poloniex_quotes, :currency_pair
  end
end
