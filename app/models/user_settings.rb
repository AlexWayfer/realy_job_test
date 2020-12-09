# frozen_string_literal: true

class UserSettings < ApplicationRecord
  ## Associations

  belongs_to :user

  ## Elasticsearch

  update_index 'users#user', :user
end
