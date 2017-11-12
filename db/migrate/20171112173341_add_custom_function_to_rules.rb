class AddCustomFunctionToRules < ActiveRecord::Migration
  def change
    add_column :rules, :custom_function, :string
  end
end
