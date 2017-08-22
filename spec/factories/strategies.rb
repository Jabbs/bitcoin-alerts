FactoryGirl.define do
  factory :strategy do
    name "MyString"
    percent_change 1
    percent_change_confinment "MyString"
    last_alert_sent_at "2017-08-21 08:31:32"
    lookback_hours 1
  end
end
