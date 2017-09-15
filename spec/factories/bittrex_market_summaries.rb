FactoryGirl.define do
  factory :bittrex_market_summary do
    market_name "MyString"
    high "9.99"
    low "9.99"
    volume "9.99"
    last "9.99"
    base_volume "9.99"
    time_stamp "2017-09-15 18:25:08"
    bid "9.99"
    ask "9.99"
    open_buy_orders 1
    open_sell_orders 1
    prev_day "9.99"
    created "2017-09-15 18:25:08"
  end
end
