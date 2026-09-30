# frozen_string_literal: true

module StarkInfra
  # # PixSubscriptionBacenId object
  #
  # A PixSubscriptionBacenId is a 29-character string that uniquely identifies a Pix subscription
  # at the BACEN (Banco Central do Brasil) level. It is composed of a prefix (e.g. "RR"),
  # the receiver bank's ISPB code, a date stamp (yyyyMMdd) and 11 random alphanumeric characters.
  #
  # ## Parameters (required):
  # - bank_code [string]: 8-digit ISPB code of the bank. ex: '20018183'
  # - prefix [string]: prefix of the bacen id. ex: 'RR'
  #
  # ## Return:
  # - PixSubscriptionBacenId string. ex: 'RR2001818320220120GD19lzAbCdE'
  class PixSubscriptionBacenId
    def self.create(bank_code, prefix)
      "#{prefix}#{BacenId.create(bank_code, '%Y%m%d')}"
    end
  end
end
