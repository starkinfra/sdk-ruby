# frozen_string_literal: true

module StarkInfra
  # # BacenId object
  #
  # A BacenId is the common body of the identifiers used at the BACEN (Banco Central do Brasil) level.
  # It is composed of the bank's ISPB code, a datetime stamp and 11 random alphanumeric characters.
  # It is the base of EndToEndId, ReturnId and PixSubscriptionBacenId.
  #
  # ## Parameters (required):
  # - bank_code [string]: 8-digit ISPB code of the bank. ex: '20018183'
  #
  # ## Parameters (optional):
  # - date_format [string, default '%Y%m%d%H%M']: strftime format of the datetime stamp.
  #
  # ## Return:
  # - BacenId string. ex: '200181832022012014505GD19lzAbCdE'
  class BacenId
    RANDOM_SOURCE = (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).freeze

    def self.create(bank_code, date_format = '%Y%m%d%H%M')
      random_string = (0...11).map { RANDOM_SOURCE.sample }.join
      "#{bank_code}#{Time.now.strftime(date_format)}#{random_string}"
    end
  end
end
