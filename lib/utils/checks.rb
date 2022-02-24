# frozen_string_literal: true

require('date')
require('starkbank-ecdsa')
require('starkbank')
require_relative('environment')

module StarkInfra
  module Utils
    class Checks
      def self.check_user(user)
        return user if user.is_a?(StarkBank::User)

        user = user.nil? ? StarkInfra.user : user
        raise(ArgumentError, 'A user is required to access our API. Check our README: https://github.com/starkinfra/sdk-ruby/') if user.nil?

        user
      end

      def self.check_language
        language = StarkInfra.language
        accepted_languages = %w[en-US pt-BR]
        raise(ArgumentError, "Select a valid language: #{accepted_languages.join(', ')}") unless accepted_languages.include?(language)

        language
      end

      def self.check_environment(environment)
        environments = StarkInfra::Utils::Environment.constants(false).map { |c| StarkInfra::Utils::Environment.const_get(c) }
        raise(ArgumentError, "Select a valid environment: #{environments.join(', ')}") unless environments.include?(environment)

        environment
      end

      def self.check_private_key(pem)
        EllipticCurve::PrivateKey.fromPem(pem)
        pem
      rescue
        raise(ArgumentError, 'Private-key must be a valid secp256k1 ECDSA string in pem format')
      end

      def self.check_date_or_datetime(data)
        return if data.nil?

        return data if data.is_a?(Time) || data.is_a?(DateTime)

        return data if data.is_a?(Date)

        data, type = check_datetime_string(data)
        type == 'date' ? Date.new(data.year, data.month, data.day) : data
      end

      def self.check_datetime(data)
        return if data.nil?

        return data if data.is_a?(Time) || data.is_a?(DateTime)

        return Time.new(data.year, data.month, data.day) if data.is_a?(Date)

        data, _type = check_datetime_string(data)
        data
      end

      def self.check_date(data)
        return if data.nil?

        return Date.new(data.year, data.month, data.day) if data.is_a?(Time) || data.is_a?(DateTime)

        return data if data.is_a?(Date)

        data, type = check_datetime_string(data)

        type == 'date' ? Date.new(data.year, data.month, data.day) : data
      end

      class << self
        private

        def check_datetime_string(data)
          data = data.to_s

          begin
            return [DateTime.strptime(data, '%Y-%m-%dT%H:%M:%S.%L+00:00'), 'datetime']
          rescue ArgumentError
          end

          begin
            return [DateTime.strptime(data, '%Y-%m-%dT%H:%M:%S+00:00'), 'datetime']
          rescue ArgumentError
          end

          begin
            return [DateTime.strptime(data, '%Y-%m-%d'), 'date']
          rescue ArgumentError
            raise(ArgumentError, 'invalid datetime string ' + data)
          end
        end
      end
    end
  end
end
