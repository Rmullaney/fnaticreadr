FactoryBot.define do
  factory :user do
    first { Faker::Name.first_name }
    last { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { 'colgate13' }
    password_confirmation { 'colgate13' }
    role { :standard }
  end
end
