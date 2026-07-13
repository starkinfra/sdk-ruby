# frozen_string_literal: true

module StarkInfra
  # # ReturnId object
  #
  # A ReturnId is a 32-character string that uniquely identifies a return Pix transaction
  # at the BACEN (Banco Central do Brasil) level. It is composed of a "D" prefix,
  # the sender bank's ISPB code (zero-padded to 8 digits), a datetime stamp (yyyyMMddHHmm),
  # and 11 random alphanumeric characters.
  #
  # ## Parameters (required):
  # - bank_code [string]: 8-digit ISPB code of the sending bank. ex: '20018183'
  #
  # ## Return:
  # - ReturnId string. ex: 'D200181832022012014505GD19lzAbCdE'
  class ReturnId
    RANDOM_SOURCE = (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).freeze

    def self.create(bank_code)
      random_string = (0...11).map { RANDOM_SOURCE.sample }.join
      "D#{bank_code}#{Time.now.strftime('%Y%m%d%H%M')}#{random_string}"
    end
  end
end
