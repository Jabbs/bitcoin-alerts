class AddComparisonTableToRules < ActiveRecord::Migration
  def up
    add_column :rules, :comparison_table, :string
    add_column :rules, :comparison_table_column, :string
    rename_column :rules, :price_ceiling, :ceiling
    rename_column :rules, :price_floor, :floor
  end

  def down
    remove_column :rules, :comparison_table
    remove_column :rules, :comparison_table_column
    rename_column :rules, :ceiling, :price_ceiling
    rename_column :rules, :floor, :price_floor
  end
end
