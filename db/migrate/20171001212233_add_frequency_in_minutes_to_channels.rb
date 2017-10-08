class AddFrequencyInMinutesToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :frequency_in_minutes, :integer
    remove_column :subscriptions, :frequency_in_minutes, :integer
  end
end
