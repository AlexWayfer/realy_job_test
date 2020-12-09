# frozen_string_literal: true

FactoryBot.define do
  factory :user_settings do
    age_preference_range = (18..100).freeze

    user { association :user, settings: instance }

    age_preference do
      min = Faker::Number.between(from: age_preference_range.begin, to: age_preference_range.end)
      min..Faker::Number.between(from: min, to: age_preference_range.end)
    end

    ## https://rationalnumbers.ru/all/13589-31-km-samoe-bolshoe-rasstoyanie-mezhdu-dvumya-tochkami-na/
    max_distance { Faker::Number.within(range: 0.0..14_000.0) }
  end
end
