class CreateSlackNotifications < ActiveRecord::Migration
  def change
    create_table :slack_notifications do |t|
      t.string :channel
      t.integer :quote_id
      t.integer :lookback_in_hours
      t.integer :percent_change_threshold
      t.text :message

      t.timestamps null: false
    end
    add_index :slack_notifications, :quote_id
  end
end
