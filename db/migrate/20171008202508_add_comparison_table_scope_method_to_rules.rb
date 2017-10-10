class AddComparisonTableScopeMethodToRules < ActiveRecord::Migration
  def change
    add_column :rules, :comparison_table_scope_method, :string
    add_column :rules, :comparison_table_scope_value, :string
  end
end
