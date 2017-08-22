class AddStrategyIdsToSchemes < ActiveRecord::Migration
  def change
    add_column :schemes, :strategy_ids, :integer, array: true, default: '{}'
  end
end
