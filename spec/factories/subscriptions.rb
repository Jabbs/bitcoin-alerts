FactoryGirl.define do
  factory :subscription do
    user_id 1
    channel_id 1
    notification_type "MyString"
    frequency_in_minutes 1
  end
end
