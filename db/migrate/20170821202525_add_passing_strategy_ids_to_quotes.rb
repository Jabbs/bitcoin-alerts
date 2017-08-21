class AddPassingStrategyIdsToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :passing_strategy_ids, :integer, array: true, default: '{}'
  end
end
