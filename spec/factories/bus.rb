FactoryBot.define do
  factory :bus do
    name { "Volvo Bus" }
    route { "Patna - Delhi" }
    total_seat { rand(30..50) }
    sequence :registration_no do |n|
      "MP #{n}123456"
    end
    approved { false }
    association :bus_owner
    
    trait :approved_bus do
      approved { true }
    end
  end
end

