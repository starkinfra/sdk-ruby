# frozen_string_literal: false

require_relative('bacenid')

module StarkInfra
    module EndToEndId
        def self.create(bank_code)
            'E' << StarkInfra::Utils::BacenId._create(bank_code)
        end
    end
end