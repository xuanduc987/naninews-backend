FactoryGirl.define do
  sequence(:content) { |n| "My Text Number #{n}" }

  factory :comment do
    association :post, factory: :post, strategy: :build
    association :user, factory: :user, strategy: :build
    content
  end
end
