# frozen_string_literal: true

require('starkcore')

module StarkInfra
  module Utils
    module Rest

      def self.get_page(resource_name:, resource_maker:, user:, **query)
        return StarkCore::Utils::Rest.get_page(
          resource_name: resource_name,
          resource_maker: resource_maker,
          sdk_version: StarkInfra::SDK_VERSION,
          host: StarkInfra::HOST,
          api_version: StarkInfra::API_VERSION,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          **query
        )
      end

      def self.get_stream(resource_name:, resource_maker:, user:, **query)
        return StarkCore::Utils::Rest.get_stream(
          resource_name: resource_name,
          resource_maker: resource_maker,
          sdk_version: StarkInfra::SDK_VERSION,
          host: StarkInfra::HOST,
          api_version: StarkInfra::API_VERSION,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          **query
        )
      end

      def self.get_id(resource_name:, resource_maker:, user:, id:, **query)
        return StarkCore::Utils::Rest.get_id(
          resource_name: resource_name,
          resource_maker: resource_maker,
          sdk_version: StarkInfra::SDK_VERSION,
          host: StarkInfra::HOST,
          api_version: StarkInfra::API_VERSION,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          id: id,
          **query
        )
      end

      def self.get_content(resource_name:, resource_maker:, user:, sub_resource_name:, id:, **query)
        return StarkCore::Utils::Rest.get_content(
          resource_name: resource_name,
          resource_maker: resource_maker,
          sdk_version: StarkInfra::SDK_VERSION,
          host: StarkInfra::HOST,
          api_version: StarkInfra::API_VERSION,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          sub_resource_name: sub_resource_name, 
          id: id,
          **query
        )
      end

      def self.get_sub_resource(resource_name:, sub_resource_maker:, sub_resource_name:, user:, id:, **query)
        return StarkCore::Utils::Rest.get_sub_resource(
          resource_name: resource_name,
          sub_resource_maker: sub_resource_maker, 
          sub_resource_name: sub_resource_name, 
          sdk_version: StarkInfra::SDK_VERSION, 
          host: StarkInfra::HOST, 
          api_version: StarkInfra::API_VERSION, 
          user: user ? user : StarkInfra.user, 
          language: StarkInfra.language, 
          timeout: StarkInfra.timeout, 
          id: id, 
          **query
        )
      end

      def self.get_sub_resources(resource_name:, sub_resource_maker:, sub_resource_name:, user:, id:, **query)
        return StarkCore::Utils::Rest.get_sub_resource(
          resource_name: resource_name,
          sub_resource_maker: sub_resource_maker, 
          sub_resource_name: sub_resource_name, 
          sdk_version: StarkInfra::SDK_VERSION, 
          host: StarkInfra::HOST, 
          api_version: StarkInfra::API_VERSION, 
          user: user ? user : StarkInfra.user, 
          language: StarkInfra.language, 
          timeout: StarkInfra.timeout, 
          id: id, 
          **query
        )
      end

      def self.post(resource_name:, resource_maker:, user:, entities:, **query)
        return StarkCore::Utils::Rest.post(
          resource_name: resource_name,
          resource_maker: resource_maker,
          sdk_version: StarkInfra::SDK_VERSION,
          host: StarkInfra::HOST,
          api_version: StarkInfra::API_VERSION,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          entities: entities,
          **query
        )
      end

      def self.post_single(resource_name:, resource_maker:, user:, entity:)
        return StarkCore::Utils::Rest.post_single(
          resource_name: resource_name,
          resource_maker: resource_maker,
          sdk_version: StarkInfra::SDK_VERSION,
          host: StarkInfra::HOST,
          api_version: StarkInfra::API_VERSION,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          entity: entity
        )
      end

      def self.post_raw(path:, payload:, user:, **query)
        return StarkCore::Utils::Rest.post_raw(
          host: StarkInfra::HOST,
          sdk_version: StarkInfra::SDK_VERSION,
          user: user ? user : StarkInfra.user,
          path: path,
          payload: payload,
          api_version: StarkInfra::API_VERSION,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          **query,
        )
      end

      def self.delete_id(resource_name:, resource_maker:, user:, id:)
        return StarkCore::Utils::Rest.delete_id(
          resource_name: resource_name,
          resource_maker: resource_maker,
          sdk_version: StarkInfra::SDK_VERSION,
          host: StarkInfra::HOST,
          api_version: StarkInfra::API_VERSION,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          id: id
        )
      end

      def self.patch_id(resource_name:, resource_maker:, user:, id:, **payload)
        return StarkCore::Utils::Rest.patch_id(
          resource_name: resource_name,
          resource_maker: resource_maker,
          sdk_version: StarkInfra::SDK_VERSION,
          host: StarkInfra::HOST,
          api_version: StarkInfra::API_VERSION,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.timeout,
          id: id,
          **payload
        )
      end
    end
  end
end
