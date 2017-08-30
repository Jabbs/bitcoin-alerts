class AddPrecisionAndScaleToTrades < ActiveRecord::Migration
  def change
    change_column :trades, :price, :decimal, precision: 20, scale: 10
    change_column :trades, :size, :decimal, precision: 20, scale: 10
  end
end
