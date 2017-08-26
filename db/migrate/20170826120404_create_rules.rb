class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.integer :strategy_id
      t.decimal :percent_increase, precision: 12, scale: 4
      t.decimal :percent_decrease, precision: 12, scale: 4
      t.integer :lookback_minutes
      t.string :comparison_logic
      t.string :operator

      t.timestamps null: false
    end
    add_index :rules, :strategy_id
    remove_column :strategies, :percent_change_confinment
    remove_column :strategies, :percent_change
    remove_column :strategies, :lookback_hours
  end
end
