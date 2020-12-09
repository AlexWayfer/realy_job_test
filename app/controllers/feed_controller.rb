# frozen_string_literal: true

## Controller for a feed of users
class FeedController < ApplicationController
  def index
    render json: UsersIndex.query
  end
end
