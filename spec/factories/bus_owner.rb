FactoryBot.define do
  factory :bus_owner,class: "User" do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "111111" }
    sequence :registration_no do |n|
      "BUSOWNER#{n}12345"
    end
    role { "bus_owner" }
    confirmed_at { Time.now }
  end
end
