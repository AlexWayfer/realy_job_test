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

  shared_context 'with JSON body' do
    subject(:body) { JSON.parse(response.body) }
  end

  describe 'GET /' do
    def build_uri
      '/feed'
    end

    def make_request(uri)
      get uri
    end

    subject { response }

    before { make_request uri }

    let(:uri) { build_uri }

    let(:expected_user) do
      include(
        'name' => a_string_matching(/^([\w.']+ ?)+$/),
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

    include_examples 'it has successful HTTP status'

    describe 'body' do
      include_context 'with JSON body'

      it 'returns all data in correct format' do
        expect(body).to match Array.new(initial_number_of_users, expected_user)
      end
    end

    describe 'pagination' do
      def self.build_page_data_name(page)
        "page_#{page}_data"
      end

      def self.build_page_data(page)
        let(build_page_data_name(page)) do
          make_request build_uri page: page
          JSON.parse(response.body)
        end
      end

      def build_uri(page:)
        "#{super()}?page=#{page}"
      end

      let(:uri) { build_uri page: page }
      let(:initial_number_of_users) { 15 }
      let(:per_page_default) { 10 }
      let(:per_page) { per_page_default }

      shared_examples 'returns correct formatted data' do
        it 'returns correct formatted data' do
          expect(body).to all match expected_user
        end
      end

      shared_examples 'successful page' do |page|
        let(:page) { page }

        include_examples 'it has successful HTTP status'
      end

      shared_examples 'successful page with data' do |page|
        include_examples 'successful page', page

        describe 'body' do
          include_context 'with JSON body'

          include_examples 'returns correct formatted data'

          describe 'size' do
            subject { super().size }

            it { is_expected.to eq expected_body_size }
          end

          (1..page.pred).each do |exclude_page|
            build_page_data exclude_page

            it "does not includes data from page ##{exclude_page}" do
              expect(body).not_to include send(self.class.build_page_data_name(exclude_page))
            end
          end
        end
      end

      shared_examples 'full page' do |page|
        include_examples 'successful page with data', page do
          let(:expected_body_size) { per_page }
        end
      end

      shared_examples 'last page' do |page|
        include_examples 'successful page with data', page do
          let(:expected_body_size) { initial_number_of_users % per_page }
        end
      end

      shared_examples 'empty page' do |page|
        include_examples 'successful page', page

        describe 'body' do
          include_context 'with JSON body'

          it { is_expected.to be_empty }
        end
      end

      shared_examples 'page #0' do
        include_examples 'successful page', 0

        describe 'body' do
          include_context 'with JSON body'

          build_page_data 1

          it 'equals to page #1 data' do
            expect(body).to eq page_1_data
          end
        end
      end

      describe 'page #1' do
        include_examples 'full page', 1
      end

      describe 'page #2' do
        include_examples 'last page', 2
      end

      include_examples 'page #0'

      describe 'page #3' do
        include_examples 'empty page', 3
      end

      describe 'custom `per_page`' do
        def build_uri(page:)
          "#{super(page: page)}&per_page=#{per_page}"
        end

        let(:per_page) { 6 }

        describe 'page #1' do
          include_examples 'full page', 1
        end

        describe 'page #2' do
          include_examples 'full page', 2
        end

        describe 'page #3' do
          include_examples 'last page', 3
        end

        include_examples 'page #0'

        describe 'page #4' do
          include_examples 'empty page', 4
        end
      end
    end
  end
end
