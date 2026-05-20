# frozen_string_literal: true

require('date')

class BacenId
  def self.pixpullsubscription_bacen_id(bank_code)
    'RR' + bank_code + Time.now.utc.strftime('%Y%m%d%H%M') + rand(10**6...10**7).to_s
  end
end
