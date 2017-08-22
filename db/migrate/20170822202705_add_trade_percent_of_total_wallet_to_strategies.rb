class AddTradePercentOfTotalWalletToStrategies < ActiveRecord::Migration
  def change
    add_column :strategies, :trade_percent_of_account_balance, :integer
  end
end
