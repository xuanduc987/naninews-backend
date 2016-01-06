FactoryGirl.define do
  sequence(:title) { |n| "Title Number #{n}" }
  sequence(:url) { |n| "http://example.com/#{n}" }

  factory :post do
    url
    title
    association :user, factory: :user, strategy: :build
  end
end
