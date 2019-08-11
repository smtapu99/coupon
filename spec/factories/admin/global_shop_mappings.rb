module Admin
  FactoryGirl.define do
    factory :global_shop_mapping, class: Admin::Global::ShopMapping do
      association :global, factory: :global
      association :country, factory: :country
    end
  end
end
