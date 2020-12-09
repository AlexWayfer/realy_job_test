# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    age { Faker::Number.between(from: 18, to: 100) }
    location do
      RGeo::Cartesian.preferred_factory.point(Faker::Address.longitude, Faker::Address.latitude)
    end
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }

    # settings factory: :user_settings
    settings { association :user_settings, user: instance }

    last_visit { Faker::Time.between(from: DateTime.now - 30, to: DateTime.now) }
  end
end
