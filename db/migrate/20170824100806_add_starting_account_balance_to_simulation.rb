class AddStartingAccountBalanceToSimulation < ActiveRecord::Migration
  def change
    add_column :simulations, :usd_starting_account_balance, :decimal, precision: 25, scale: 10
    add_column :simulations, :usd_account_balance, :decimal, precision: 25, scale: 10
    add_column :simulations, :btc_starting_account_balance, :decimal, precision: 25, scale: 10
    add_column :simulations, :btc_account_balance, :decimal, precision: 25, scale: 10
    add_column :simulations, :eth_starting_account_balance, :decimal, precision: 25, scale: 10
    add_column :simulations, :eth_account_balance, :decimal, precision: 25, scale: 10
    add_column :simulations, :ltc_starting_account_balance, :decimal, precision: 25, scale: 10
    add_column :simulations, :ltc_account_balance, :decimal, precision: 25, scale: 10
  end
end
