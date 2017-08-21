class DropBitcoinQuotes < ActiveRecord::Migration
  def up
    drop_table :bitcoin_quotes
  end

  def down
  end
end
