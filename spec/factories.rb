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
    size 2
  end

  factory :metric do
    name 'General'
  end

  factory :token do
  end

  factory :user do
    external_id 'U1234'
  end
end

