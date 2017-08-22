class AddCategoryToStrategies < ActiveRecord::Migration
  def up
    add_column :strategies, :category, :string
    add_index :strategies, :category
    Strategy.all.each { |s| s.update_attribute(:category, "buy") }
  end

  def down
    remove_column :strategies, :category
  end
end
