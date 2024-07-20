require('starkcore')

module StarkInfra
  module Utils
    module Parse
      def self.parse_and_verify(content:, signature:, user: nil, resource:, key: nil)
        return StarkCore::Utils::Parse.parse_and_verify(
          content: content, 
          signature: signature, 
          sdk_version: StarkInfra::SDK_VERSION,
          api_version: StarkInfra::API_VERSION,
          host: StarkInfra::HOST,
          resource: resource,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.language,
          key: key
        )
      end

      def self.verify(content:, signature:, user: nil)
        return StarkCore::Utils::Parse.verify(
          content: content, 
          signature: signature, 
          sdk_version: StarkInfra::SDK_VERSION,
          api_version: StarkInfra::API_VERSION,
          host: StarkInfra::HOST,
          user: user ? user : StarkInfra.user,
          language: StarkInfra.language,
          timeout: StarkInfra.language
        )
      end
    end
  end
end
