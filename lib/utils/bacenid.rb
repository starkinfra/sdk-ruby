# frozen_string_literal: false

require('date')

module StarkInfra
  module Utils
    module BacenId
      def self._create(bank_code)
        random_source = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'.split('')
        random_string = ''

        11.times do
          random_string << random_source[rand(random_source.length)]
        end
        bank_code + DateTime.now.strftime('%Y%m%d%H%M') << random_string
      end
    end
  end
end
