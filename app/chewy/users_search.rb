# frozen_string_literal: true

## Form object for Users search
## https://www.toptal.com/ruby-on-rails/elasticsearch-for-ruby-on-rails-an-introduction-to-chewy#searching
class UsersSearch
  include ActiveData::Model

  # attribute :query, String
  attribute :visit_recently, Boolean, default: false

  ## Pagination
  attribute :page, Integer, default: 1
  ## There is should be a maximum limitation, but I don't give a fuck
  attribute :per_page, Integer, default: 10

  def index
    UsersIndex
  end

  def search
    ## I'm not sure about `index.all`, but I didn't find proper information
    ## about methods and paginations.
    ## I found a few articles about `chewy` usage:
    ## * https://www.toptal.com/ruby-on-rails/elasticsearch-for-ruby-on-rails-an-introduction-to-chewy#searching
    ## * https://manakuro.medium.com/chewy-gem-with-active-model-serializers-in-ruby-on-rails-5-2-3-a6f88e0330b5
    ## but there is broken code.
    ## So... I've done my best.

    [index.all, query_string, visit_recently_filter].compact.reduce(:merge)
      .page(page).per(per_page)
  end

  def query_string
    # return unless query?
    #
    # index.query(
    #   query_string: { fields: %i[name phone_number], query: query, default_operator: 'and' }
    # )
  end

  def visit_recently_filter
    return unless visit_recently

    index.filter(range: { last_visit: { gte: 1.week.ago } })
  end
end
