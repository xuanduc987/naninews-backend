FactoryGirl.define do
  factory :vote do
    association :user, factory: :user, strategy: :build
    association :post, factory: :post, strategy: :build
  end
end
