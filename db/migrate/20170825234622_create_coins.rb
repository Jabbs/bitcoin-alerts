class CreateCoins < ActiveRecord::Migration
  def change
    create_table :coins do |t|
      t.decimal :acquired_price, precision: 20, scale: 10
      t.string :currency
      t.integer :wallet_id
      t.integer :order_id
      t.decimal :sold_price, precision: 20, scale: 10
      t.datetime :sold_at

      t.timestamps null: false
    end
    add_index :coins, :wallet_id
    add_index :coins, :sold_at
    add_index :coins, :created_at
  end
end
