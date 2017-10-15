class AddMessageToChannelNotifications < ActiveRecord::Migration
  def change
    add_column :channel_notifications, :message, :text
  end
end
