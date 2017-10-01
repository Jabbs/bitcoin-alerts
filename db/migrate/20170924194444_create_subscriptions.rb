class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :channel_id
      t.string :notification_type
      t.integer :frequency_in_minutes

      t.timestamps null: false
    end
    add_index :subscriptions, :user_id
    add_index :subscriptions, :channel_id
  end
end
