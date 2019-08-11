FactoryGirl.define do

  factory :contact_form do
    name "Test"
    email "test@test.com"
    phone "9189323232"
    reason "Valid reason"
    message "Valid message"
  end

  factory :partner_form do
    name "Test"
    email "test@test.com"
    domain "examplw.com"
    message "Valid message"
  end

  factory :report_form do
    name "Test"
    email "test@test.com"
    shopname "Anything"
    discount 10
    link_to_offer "www.example.com"
    remark "Test"
  end
end
