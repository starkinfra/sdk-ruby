# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # PixDomain::Certificate object
  #
  # The Certificate object displays the certificate information from a specific domain.
  #
  # ## Attributes (return-only):
  # - content [string]: certificate of the Pix participant in PEM format.
  class Certificate < StarkCore::Utils::SubResource
    attr_reader :content
    def initialize(content: nil)
      @content = content
    end

    def self.resource
      {
        resource_name: 'Certificate',
        resource_maker: proc { |json|
          Certificate.new(
            content: json['content']
          )
        }
      }
    end
  end
end
