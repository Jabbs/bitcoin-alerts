class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.datetime :time
      t.integer :trade_id, null: false
      t.decimal :price
      t.decimal :size
      t.string :side
      t.string :currency_pair

      t.timestamps null: false
    end
    add_index :trades, :trade_id, unique: true
    add_index :trades, :size
    add_index :trades, :side
    add_index :trades, :price
    add_index :trades, :currency_pair
    add_index :trades, :time
  end
end
