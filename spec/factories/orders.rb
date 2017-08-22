FactoryGirl.define do
  factory :order do
    client_id "MyString"
    price "MyString"
    size "MyString"
    currency_pair "MyString"
    side "MyString"
    stp "MyString"
    type ""
    time_in_force "MyString"
    post_only false
    fill_fees "MyString"
    filled_size "MyString"
    executed_value "MyString"
    status "MyString"
    settled false
  end
end
