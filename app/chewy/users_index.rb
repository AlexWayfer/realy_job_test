# frozen_string_literal: true

class UsersIndex < Chewy::Index
  define_type User.includes(:settings) do
    field :name, :age, :location, :phone_number, :last_visit
    field :settings do # the same block syntax for multi_field, if `:type` is specified
      field :age_preference
      field :max_distance
    end
  end
end
