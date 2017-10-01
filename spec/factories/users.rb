FactoryGirl.define do
  factory :user do
    username "MyString"
    email "MyString"
    password_digest "MyString"
    password_reset_token "MyString"
    password_reset_sent_at "2017-09-24 14:45:43"
    verified false
    verification_token "MyString"
    verification_sent_at "2017-09-24 14:45:43"
  end
end
