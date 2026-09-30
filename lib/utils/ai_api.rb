# frozen_string_literal: true

require('starkcore')
require_relative('rest')

module StarkInfra
  module Utils
    # The AI routes answer under keys starkcore cannot derive from the resource name (it reads the last word of the
    # name, and 'speeches' is not 'speechs'), and some creates answer with a list, so the AI resources read the
    # responses themselves through these helpers. Every call raises on 400 and 500, which the raw helpers do not by default.
    module AiApi
      # the payloads are written out key by key instead of going through cast_json_to_api_format, which would
      # also convert the keys the user chose inside a metadata schema; this only drops the absent fields
      def self.drop_nil(payload)
        payload.compact
      end

      def self.camel_names(names)
        names&.map { |name| StarkCore::Utils::Case.snake_to_camel(name) }
      end

      def self.fields_and_expand(fields, expand)
        drop_nil(fields: camel_names(fields), expand: camel_names(expand))
      end

      def self.create_one(path:, key:, resource_maker:, payload:, user:, query: nil)
        response = StarkInfra::Utils::Rest.post_raw(
          path: path,
          payload: payload,
          query: query,
          raiseException: true,
          user: user
        )
        StarkCore::Utils::API.from_api_json(resource_maker, response.json[key])
      end

      def self.get_one(path:, key:, resource_maker:, id:, user:, query: nil)
        response = StarkInfra::Utils::Rest.get_raw(path: "#{path}/#{id}", query: query, raiseException: true, user: user)
        StarkCore::Utils::API.from_api_json(resource_maker, response.json[key])
      end

      def self.patch_one(path:, key:, resource_maker:, id:, payload:, user:)
        response = StarkInfra::Utils::Rest.patch_raw(
          path: "#{path}/#{id}",
          payload: payload,
          raiseException: true,
          user: user
        )
        StarkCore::Utils::API.from_api_json(resource_maker, response.json[key])
      end

      def self.list_all(path:, key:, resource_maker:, user:, query: nil)
        Enumerator.new do |enum|
          response = StarkInfra::Utils::Rest.get_raw(path: path, query: query, raiseException: true, user: user)
          response.json[key].each { |entity| enum << StarkCore::Utils::API.from_api_json(resource_maker, entity) }
        end
      end

      def self.delete_many(path:, key:, resource_maker:, ids:, user:)
        response = StarkInfra::Utils::Rest.delete_raw(path: path, query: { ids: ids }, raiseException: true, user: user)
        response.json[key].map { |entity| StarkCore::Utils::API.from_api_json(resource_maker, entity) }
      end
    end
  end
end
