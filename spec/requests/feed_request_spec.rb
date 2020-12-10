# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feeds', type: :request do
  let(:initial_number_of_users) { 3 }

  before do
    Chewy.strategy(:atomic) do
      create_list(:user, initial_number_of_users)
    end
  end

  shared_examples 'it has successful HTTP status' do
    it { is_expected.to have_http_status(:success) }
  end

  describe 'GET /' do
    subject { response }

    let(:uri) { '/feed' }

    before { get uri }

    include_examples 'it has successful HTTP status'

    describe 'body' do
      subject(:body) { JSON.parse(response.body) }

      let(:expected_user) do
        include(
          'name' => a_string_matching(/^([\w.]+ ?)+$/),
          'age' => be_between(18, 100),
          'phone_number' => a_string_matching(/^\+\d+$/),
          'location' => a_string_matching(/^POINT \(-?\d+\.\d+ -?\d+\.\d+\)$/),
          'last_visit' => a_string_matching(/^20\d{2}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z$/),
          'settings' => include(
            ## Custom serializer can help to parse this as `Range`
            'age_preference' => a_string_matching(/^\d{2,3}\.\.\.\d{2,3}$/),
            'max_distance' => be_between(0.0, 14_000.0)
          )
        )
      end

      it 'returns all data in correct format' do
        expect(body).to match Array.new(initial_number_of_users, expected_user)
      end
    end
  end
end
