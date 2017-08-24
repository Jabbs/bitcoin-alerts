class RemoveClientIdUniqFromOrders < ActiveRecord::Migration

  def up
    remove_index :orders, :client_id
    add_index :orders, :client_id
  end

  def down
    remove_index :orders, :client_id
  end
end
