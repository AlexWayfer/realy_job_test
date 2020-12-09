# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feeds', type: :request do
  describe 'GET /' do
    subject { response }

    before { get '/feed' }

    it { is_expected.to have_http_status(:success) }

    describe 'body' do
      subject { JSON.parse(super().body) }

      it { is_expected.to match 'response' => 'Hello!' }
    end
  end
end
