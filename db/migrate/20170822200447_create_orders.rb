class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :client_id, null: false
      t.string :price
      t.string :size
      t.string :currency_pair
      t.string :side
      t.string :stp
      t.string :order_type
      t.string :time_in_force
      t.boolean :post_only
      t.string :fill_fees
      t.string :filled_size
      t.string :executed_value
      t.string :status
      t.boolean :settled

      t.timestamps null: false
    end
    add_index :orders, :client_id, unique: true
  end
end
