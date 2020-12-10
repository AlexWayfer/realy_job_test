## https://github.com/toptal/chewy/issues/708#issuecomment-673747704

# frozen_string_literal: true

require 'elasticsearch'
require 'chewy'

# Compatibility workaround for ElasticSearch 7.8
# One of issues related to Chewy 7.x compatibility: https://github.com/toptal/chewy/issues/673
module Chewy
  class Index
    class << self
      def mappings_hash
        mappings = types.map(&:mappings_hash).inject(:merge)
        mappings.present? ? { mappings: mappings } : {}
      end
    end

    module Actions
      extend ActiveSupport::Concern

      module ClassMethods
        def create!(suffix = nil, **options)
          options.reverse_merge!(alias: true)
          general_name = index_name
          suffixed_name = index_name(suffix: suffix)

          body = specification_hash
          if options[:alias] && suffixed_name != general_name
            body[:aliases] = { general_name => {} }
          end
          result = client.indices.create(index: suffixed_name, body: body)

          Chewy.wait_for_status if result
          result
        end
      end
    end
  end

  module Fields
    class Root
      def mappings_hash
        mappings = super
        mappings[name].delete(:type)
        if dynamic_templates.present?
          mappings[name][:dynamic_templates] ||= []
          mappings[name][:dynamic_templates].concat dynamic_templates
        end

        mappings[name][:_parent] = parent.is_a?(Hash) ? parent : { type: parent } if parent
        mappings[name]
      end
    end
  end

  module Search
    class Request
      def count
        if performed?
          total
        else
          count = Chewy.client.count(only(WHERE_STORAGES).render)['count']
          if count.is_a?(Hash)
            count['value']
          else
            count
          end
        end
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        0
      end
    end

    class Response
      def total
        @total ||= hits_root['total'].try { |h| h['value'] } || 0
      end
    end

    class Parameters
      def render_query_string_params
        query_string_storages = @storages.select do |storage_name, _|
          QUERY_STRING_STORAGES.include?(storage_name)
        end

        r = query_string_storages.values.inject({}) do |result, storage|
          result.merge!(storage.render || {})
        end
        r.delete(:type)
        r
      end
    end

    class Loader
      def derive_type(index, type)
        (@derive_type ||= {})[[index, type]] ||= begin
          index_class = derive_index(index)
          raise Chewy::UnderivableType, "Can not find index named `#{index}`" unless index_class

          index_class.type_hash.values.first
        end
      end
    end
  end

  class Type
    module Mapping
      extend ActiveSupport::Concern

      module ClassMethods
        def mappings_hash
          root.mappings_hash
        end
      end
    end

    module Import
      class BulkRequest
        def request_base
          @request_base ||= {
            index: @type.index_name(suffix: @suffix)
          }.merge!(@bulk_options)
        end
      end

      class JournalBuilder
        def bulk_body
          Chewy::Type::Import::BulkBuilder.new(
            Chewy::Stash::Journal::Journal,
            index: [
              entries(:index, @index),
              entries(:delete, @delete)
            ].compact
          ).bulk_body.each do |item|
            item.values.first.merge!(
              _index: Chewy::Stash::Journal.index_name
            )
          end
        end
      end
    end
  end
end

# Fix counts
Elasticsearch::Transport::Client.prepend(
  Module.new do
    def search(arguments = {})
      arguments[:track_total_hits] = true
      super arguments
    end
  end
)
