class CreateChannelNotifications < ActiveRecord::Migration
  def change
    create_table :channel_notifications do |t|
      t.integer :channel_id
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :channel_notifications, [:channel_id]
    add_index :channel_notifications, [:user_id]
  end
end
