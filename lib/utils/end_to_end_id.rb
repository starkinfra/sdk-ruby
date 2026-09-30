# frozen_string_literal: true

module StarkInfra
  # # EndToEndId object
  #
  # An EndToEndId is a 32-character string that uniquely identifies a Pix transaction
  # at the BACEN (Banco Central do Brasil) level. It is composed of an "E" prefix,
  # the sender bank's ISPB code, a datetime stamp (yyyyMMddHHmm) and 11 random alphanumeric characters.
  #
  # ## Parameters (required):
  # - bank_code [string]: 8-digit ISPB code of the sending bank. ex: '20018183'
  #
  # ## Return:
  # - EndToEndId string. ex: 'E200181832022012014505GD19lzAbCdE'
  class EndToEndId
    def self.create(bank_code)
      "E#{BacenId.create(bank_code)}"
    end
  end
end
