FactoryGirl.define do
  factory :html_document do
    meta_robots ""
    meta_keywords ""
    meta_description ""
    meta_title ""
    content ""
    welcome_text ""
    h1 ""
    h2 ""
    created_at ""
    updated_at ""
    head_scripts ""

    # htmlable_id ""
    # htmlable_type ""

    trait :with_noindex do
      meta_robots 'noindex,follow'
    end

    trait :with_index do
      meta_robots 'index,follow'
    end

  end
end

