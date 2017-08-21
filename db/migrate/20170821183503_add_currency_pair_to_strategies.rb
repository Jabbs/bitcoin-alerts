class AddCurrencyPairToStrategies < ActiveRecord::Migration
  def up
    add_column :strategies, :currency_pair, :string
    Strategy.all.each { |s| s.update_attribute(:currency_pair, "BTC-USD") }
    add_index :strategies, :currency_pair
  end

  def down
    remove_column :strategies, :currency_pair
  end
end
