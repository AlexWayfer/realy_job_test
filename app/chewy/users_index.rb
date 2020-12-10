# frozen_string_literal: true

class UsersIndex < Chewy::Index
  define_type User.includes(:settings) do
    field :name, type: 'text'
    field :age, type: 'byte'
    field :location, type: 'geo_point'
    field :phone_number, type: 'text' ## maybe there can be better type/analyzer
    field :last_visit, type: 'date'

    field :settings do
      # field :age_preference, type: 'integer_range' do
      #   field :gte, value: ->(settings) { p settings.age_preference.begin }
      #   field :lte, value: ->(settings) { p settings.age_preference.end }
      # end
      field :age_preference, type: 'integer_range', value: (lambda do |settings|
        range = settings.age_preference
        { gte: range.begin, lte: range.end }
      end)

      field :max_distance, type: 'short'
    end
  end
end
