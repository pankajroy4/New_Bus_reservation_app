FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "111111" }
    role { "user" }
    confirmed_at { Time.now }
  end
end
