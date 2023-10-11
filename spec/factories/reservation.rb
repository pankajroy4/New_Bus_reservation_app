FactoryBot.define do
  factory :reservation do
    date { Date.today}
    association :user
    association :bus
    association :seat
  end
end
