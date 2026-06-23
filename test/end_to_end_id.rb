# frozen_string_literal: false

require('date')
require('starkinfra')

module StarkInfra
  module EndToEndId
    def self.create(bank_code)
      random_source = [*'0'..'9', *'a'..'z', *'A'..'Z']
      random_string = Array.new(11) { random_source.sample }.join
      "E#{bank_code}#{Time.now.utc.strftime('%Y%m%d%H%M')}#{random_string}"
    end
  end

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

    def self.pixpullrequest_end_to_end_id(ispb)
      chars = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a
      'E' + ispb + Time.now.utc.strftime('%Y%m%d%H%M') + (0...11).map { chars[rand(chars.length)] }.join
    end
  end
end
