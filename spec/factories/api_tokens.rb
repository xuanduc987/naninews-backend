FactoryGirl.define do
  factory :api_token do
    association :user, factory: :user, strategy: :build
  end
end
