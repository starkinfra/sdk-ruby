# frozen_string_literal: true
require_relative('sub_resource')

module StarkInfra
  module Utils
    class Resource < StarkInfra::Utils::SubResource
      attr_reader :id
      def initialize(id = nil)
        @id = id
      end
    end
  end
end
