# frozen_string_literal: true

require('json')
require('starkbank-ecdsa')
require_relative('api')
require_relative('cache')
require_relative('request')
require_relative('../error')\


module StarkInfra
  module Utils
    module Parse
      def self.parse_and_verify(content:, signature:, user: nil, resource:, key: nil)
        event = StarkInfra::Utils::API.from_api_json(resource[:resource_maker], JSON.parse(content))
        if key != nil
          event = StarkInfra::Utils::API.from_api_json(resource[:resource_maker], JSON.parse(content)[key])
        end

        begin
          signature = EllipticCurve::Signature.fromBase64(signature)
        rescue
          raise(StarkInfra::Error::InvalidSignatureError, 'The provided signature is not valid')
        end
  
        return event if verify_signature(content: content, signature: signature, user: user)
  
        return event if verify_signature(content: content, signature: signature, user: user, refresh: true)
  
        raise(StarkInfra::Error::InvalidSignatureError, 'The provided signature and content do not match the Stark Infra public key')
      end

      def self.verify_signature(content:, signature:, user:, refresh: false)
        public_key = StarkInfra::Utils::Cache.starkinfra_public_key
        if public_key.nil? || refresh
          pem = get_public_key_pem(user)
          public_key = EllipticCurve::PublicKey.fromPem(pem)
          StarkInfra::Utils::Cache.starkinfra_public_key = public_key
        end
        EllipticCurve::Ecdsa.verify(content, signature, public_key)
      end

      def self.get_public_key_pem(user)
        StarkInfra::Utils::Request.fetch(method: 'GET', path: 'public-key', query: { limit: 1 }, user: user).json['publicKeys'][0]['content']
      end
    end
  end
end


