# frozen_string_literal: true

## Controller for a feed of users
class FeedController < ApplicationController
  def index
    search = UsersSearch.new(search_params)

    # result = search.search.source(:id).objects
    result = search.search.source(:id).load(
      user: { scope: User.includes(:settings) }
    ).objects

    ## Probably we should use `:only` and/or `:except` here or even custom serializers
    render json: result, include: :settings
  end

  private

  def search_params
    params.permit(:search, :visit_recently, :page, :per_page)
  end
end
