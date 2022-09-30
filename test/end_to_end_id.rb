# frozen_string_literal: false

require('date')
require('starkinfra')

module StarkInfra
  module EndToEndIdTest
    def self.get_to_reverse
      cursor = nil
      end_to_end_ids = []
      while end_to_end_ids.empty?
        requests, cursor = StarkInfra::PixRequest.page(
          cursor: cursor,
          limit: 30,
          status: 'success'
        )
        requests.each do |request|
          if request.flow == 'in' && request.amount >= 1
            end_to_end_ids.append(request.end_to_end_id)
          end
        end
        break if cursor.nil?
      end
      if end_to_end_ids.empty?
        raise Exception, 'Sorry, There are no PixRequests to be reversed in your workspace'
      end

      end_to_end_ids[0]
    end
  end
end
