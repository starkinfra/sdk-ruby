# frozen_string_literal: true

module StarkInfra
  module Utils
    module Cache
      @starkinfra_public_key = nil
      class << self; attr_accessor :starkinfra_public_key; end
    end
  end
end
