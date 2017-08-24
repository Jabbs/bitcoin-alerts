class CreateSimulations < ActiveRecord::Migration
  def change
    create_table :simulations do |t|
      t.integer :scheme_id
      t.integer :starting_quote_id
      t.integer :ending_quote_id
      t.datetime :completed_at

      t.timestamps null: false
    end
    add_index :simulations, :scheme_id
  end
end
