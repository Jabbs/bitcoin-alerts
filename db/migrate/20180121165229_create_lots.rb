class CreateLots < ActiveRecord::Migration
  def change
    create_table :lots do |t|
      t.string :receiving_account_symbol
      t.decimal :aquired_asset_amount, precision: 25, scale: 10
      t.decimal :remaining_asset_amount, precision: 25, scale: 10
      t.decimal :usd_cost, precision: 25, scale: 10
      t.datetime :transaction_time

      t.timestamps null: false
    end
  end
end
