# frozen_string_literal: true

module BacenId
  def self.create(prefix, bank_code)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    random = (0...11).map { chars.sample }.join
    "#{prefix}#{bank_code}#{Time.now.strftime('%Y%m%d%H%M')}#{random}"
  end
end
