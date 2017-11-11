class AddFrequencyTypeToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :frequency_type, :string, default: "continuous"
  end
end
