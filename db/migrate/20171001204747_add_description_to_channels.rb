class AddDescriptionToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :description, :text
    add_column :channels, :source_url, :text
    add_column :channels, :source_name, :string
  end
end
