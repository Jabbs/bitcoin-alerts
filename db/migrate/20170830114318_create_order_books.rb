class CreateOrderBooks < ActiveRecord::Migration
  def change
    create_table :order_books do |t|
      t.string :currency_pair
      t.decimal :sequence, precision: 20

      t.timestamps null: false
    end
  end
end
