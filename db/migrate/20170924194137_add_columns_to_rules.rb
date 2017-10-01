class AddColumnsToRules < ActiveRecord::Migration
  def change
    add_column :rules, :channel_id, :integer
    add_column :rules, :price_ceiling, :decimal, precision: 25, scale: 10
    add_column :rules, :price_floor, :decimal, precision: 25, scale: 10
    add_column :rules, :time_constraint_start, :datetime
    add_column :rules, :time_constraint_end, :datetime
    add_column :rules, :side, :string
    add_column :rules, :currency_pair, :string
    add_index :rules, :channel_id
  end
end
