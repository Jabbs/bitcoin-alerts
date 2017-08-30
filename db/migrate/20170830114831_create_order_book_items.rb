class CreateOrderBookItems < ActiveRecord::Migration
  def change
    create_table :order_book_items do |t|
      t.string :side
      t.decimal :price, precision: 20, scale: 10
      t.decimal :size, precision: 20, scale: 10
      t.integer :num_orders
      t.integer :order_book_id

      t.timestamps null: false
    end
  end
end
