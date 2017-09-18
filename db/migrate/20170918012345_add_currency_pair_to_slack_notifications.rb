class AddCurrencyPairToSlackNotifications < ActiveRecord::Migration
  def change
    add_column :slack_notifications, :currency_pair, :string
  end
end
