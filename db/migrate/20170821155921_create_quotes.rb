class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.string :currency_pair, null: false
      t.decimal :bid, precision: 15, scale: 2, null: false
      t.decimal :ask, precision: 15, scale: 2, null: false
      t.decimal :price, precision: 15, scale: 2, null: false
      t.decimal :size, precision: 20, scale: 10, null: false
      t.decimal :volume, precision: 20, scale: 2, null: false
      t.decimal :trade_id, precision: 20, scale: 0, null: false
      t.datetime :traded_at, null: false

      t.timestamps null: false
    end
    add_index :quotes, :traded_at
    add_index :quotes, :trade_id
    add_index :quotes, :currency_pair
  end
end
