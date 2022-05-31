# frozen_string_literal: false

require_relative('bacenid')

module StarkInfra
  module ReturnId
    def self.create(bank_code)
      'D' << StarkInfra::Utils::BacenId._create(bank_code)
    end
  end
end
