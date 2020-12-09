# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feeds', type: :request do
  let(:initial_number_of_users) { 3 }

  before do
    create_list(:user, initial_number_of_users)
  end

  describe 'GET /' do
    subject { response }

    before { get '/feed' }

    it { is_expected.to have_http_status(:success) }

    describe 'body' do
      subject(:body) { JSON.parse(response.body) }

      it do
        expect(body).to match [{ name: 'Alex', age: 18 }] * initial_number_of_users
      end
    end
  end
end
