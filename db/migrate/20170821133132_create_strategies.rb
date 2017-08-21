class CreateStrategies < ActiveRecord::Migration
  def change
    create_table :strategies do |t|
      t.string :name
      t.integer :percent_change
      t.string :percent_change_direction
      t.datetime :last_alert_sent_at
      t.integer :lookback_hours

      t.timestamps null: false
    end
  end
end
