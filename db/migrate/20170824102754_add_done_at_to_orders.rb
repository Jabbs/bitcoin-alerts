class AddDoneAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :done_at, :string
    add_column :orders, :done_reason, :string
    add_column :orders, :funds, :string
    add_column :orders, :specified_funds, :string
  end
end
