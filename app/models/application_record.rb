# frozen_string_literal: true

## Abstract model class at application level
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
