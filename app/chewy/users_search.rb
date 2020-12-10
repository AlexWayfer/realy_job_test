# frozen_string_literal: true

## Form object for Users search
## https://www.toptal.com/ruby-on-rails/elasticsearch-for-ruby-on-rails-an-introduction-to-chewy#searching
class UsersSearch
  include ActiveData::Model

  # attribute :query, String
  attribute :visit_recently, Boolean, default: false

  def index
    UsersIndex
  end

  def search
    [index, query_string, visit_recently_filter].compact.reduce(:merge)
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
