FactoryGirl.define do
  factory :rule do
    strategy_id 1
    percent_increase "9.99"
    percent_decrease "9.99"
    lookback_minutes 1
    comparison_logic "MyString"
    operator "MyString"
  end
end
