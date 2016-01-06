FactoryGirl.define do
  sequence(:email) { |n| "person#{n}@example.com" }
  sequence(:name) { |n| "person#{n}" }

  factory :user do
    email
    name
    password "password"
  end
end
