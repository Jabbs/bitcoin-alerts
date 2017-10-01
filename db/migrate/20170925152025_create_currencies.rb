class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :symbol
      t.datetime :released_at
      t.text :description
      t.boolean :active
      t.string :founder
      t.string :hash_algorithm
      t.string :timestamping_method
      t.string :color_hexidecimal
      t.string :website
      t.decimal :supply_total, precision: 25, scale: 10
      t.decimal :supply_circulating, precision: 25, scale: 10

      t.timestamps null: false
    end
  end
end
