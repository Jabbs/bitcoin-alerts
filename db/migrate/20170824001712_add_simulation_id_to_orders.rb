class AddSimulationIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :simulation_id, :integer
    add_index :orders, :simulation_id
    add_column :orders, :scheme_id, :integer
    add_index :orders, :scheme_id
  end
end
