FactoryGirl.define do
  factory :admin do
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password 'pizza1234'
    after(:build) do |u|
      u.skip_confirmation!
    end
  end

  factory :company do
    name 'Gotham Industries'
    password 'GOTHAM4EVER'
    latitude 40.712784
    longitude 74.005941
  end
end

