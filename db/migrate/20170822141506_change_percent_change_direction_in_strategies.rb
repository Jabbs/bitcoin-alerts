class ChangePercentChangeDirectionInStrategies < ActiveRecord::Migration
  def change
    remove_column :strategies, :percent_change_direction
    add_column :strategies, :percent_change_confinment, :string
    Strategy.all.each { |s| s.update_attribute(:percent_change_confinment, "floor") }
  end
end
