FactoryGirl.define do
  factory :admin do
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password 'pizza1234'
    after(:build) do |u|
      u.skip_confirmation!
    end

    trait :superadmin do
      superadmin true
    end
  end

  factory :company do
    name 'Gotham Industries'
    size 2
  end

  factory :metric do
    en 'General'
    th 'General TH'
    image_url Faker::Internet.url
  end

  factory :option do
    sequence :en do |n|
      "Option ##{n}"
    end
    sequence :th do |n|
      "Option ##{n} in TH"
    end
  end

  factory :question do
    en 'Do you like coffee?'
    th 'Do you like coffee? TH'

    factory :question_with_options do
      after(:create) do |question|
        [0, 33, 66, 100].each do |i|
          create(:option, question: question, value: i)
        end
      end
    end
  end

  factory :token do
  end

  factory :user do
    external_id 'U1234'
  end
end

