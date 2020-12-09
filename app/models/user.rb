# frozen_string_literal: true

class User < ApplicationRecord
  ## Associations

  has_one :settings, class_name: 'UserSettings', dependent: :destroy

  ## Elasticsearch

  update_index 'users#user', :self
end
