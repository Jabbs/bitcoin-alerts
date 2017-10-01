class AddCurrencyIdToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :currency_id, :integer
    add_index :channels, :currency_id
  end
end
