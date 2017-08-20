class CreateBitcoinQuotes < ActiveRecord::Migration
  def change
    create_table :bitcoin_quotes do |t|
      t.decimal :bid, null: false
      t.decimal :ask, null: false
      t.decimal :spot, null: false
      t.string :currency, null: false

      t.timestamps null: false
    end
    add_index :bitcoin_quotes, :created_at
    add_index :bitcoin_quotes, :bid
    add_index :bitcoin_quotes, :ask
    add_index :bitcoin_quotes, :spot
  end
end
