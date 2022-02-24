# frozen_string_literal: true

require('json')
require('starkbank-ecdsa')
require('net/http')
require_relative('url')
require_relative('checks')
require_relative('../error')

module StarkInfra
  module Utils
    module Request
      class Response
        attr_reader :status, :content
        def initialize(status, content)
          @status = status
          @content = content
        end

        def json
          JSON.parse(@content)
        end
      end

      def self.fetch(method:, path:, payload: nil, query: nil, user: nil)
        user = Checks.check_user(user)
        language = Checks.check_language

        base_url = {
          Environment::PRODUCTION => 'https://api.starkinfra.com/',
          Environment::SANDBOX => 'https://sandbox.api.starkinfra.com/'
        }[user.environment] + 'v2'

        url = "#{base_url}/#{path}#{StarkInfra::Utils::URL.urlencode(query)}"
        uri = URI(url)

        access_time = Time.now.to_i
        body = payload.nil? ? '' : payload.to_json
        message = "#{user.access_id}:#{access_time}:#{body}"
        signature = EllipticCurve::Ecdsa.sign(message, user.private_key).toBase64

        case method
        when 'GET'
          req = Net::HTTP::Get.new(uri)
        when 'DELETE'
          req = Net::HTTP::Delete.new(uri)
        when 'POST'
          req = Net::HTTP::Post.new(uri)
          req.body = body
        when 'PATCH'
          req = Net::HTTP::Patch.new(uri)
          req.body = body
        when 'PUT'
          req = Net::HTTP::Put.new(uri)
          req.body = body
        else
          raise(ArgumentError, 'unknown HTTP method ' + method)
        end

        req['Access-Id'] = user.access_id
        req['Access-Time'] = access_time
        req['Access-Signature'] = signature
        req['Content-Type'] = 'application/json'
        req['User-Agent'] = "Ruby-#{RUBY_VERSION}-SDK-infra-0.0.2"
        req['Accept-Language'] = language

        request = Net::HTTP.start(uri.hostname, use_ssl: true) { |http| http.request(req) }

        response = Response.new(Integer(request.code, 10), request.body)

        raise(StarkInfra::Error::InternalServerError) if response.status == 500
        raise(StarkInfra::Error::InputErrors, response.json['errors']) if response.status == 400
        raise(StarkInfra::Error::UnknownError, response.content) unless response.status == 200

        response
      end
    end
  end
end
