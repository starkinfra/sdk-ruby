# frozen_string_literal: true

require('json')

module StarkInfra
  module Error
    class StarkInfraError < StandardError
      attr_reader :message
      def initialize(message)
        @message = message
        super(message)
      end
    end

    class Error < StarkInfraError
      attr_reader :code, :message
      def initialize(code, message)
        @code = code
        @message = message
        super("#{code}: #{message}")
      end
    end

    class InputErrors < StarkInfraError
      attr_reader :errors
      def initialize(content)
        errors = []
        content.each do |error|
          errors << Error.new(error['code'], error['message'])
        end
        @errors = errors

        super(content.to_json)
      end
    end

    class InternalServerError < StarkInfraError
      def initialize(message = 'Houston, we have a problem.')
        super(message)
      end
    end

    class UnknownError < StarkInfraError
      def initialize(message)
        super("Unknown exception encountered: #{message}")
      end
    end

    class InvalidSignatureError < StarkInfraError
    end
  end
end
