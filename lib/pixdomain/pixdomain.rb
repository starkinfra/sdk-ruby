# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('certificate')

module StarkInfra
  # # PixDomain object
  #
  # The PixDomain object displays the domain name and the QR Code
  # domain certificate of Pix participants.
  # All certificates must be registered with the Central Bank.
  #
  # ## Attributes (return-only):
  # - certificates [list of PixDomain::Certificate objects]: certificate information of the Pix participant.
  # - name [string]: current active domain (URL) of the Pix participant.
  class PixDomain < StarkInfra::Utils::SubResource
    attr_reader :certificates, :name
    def initialize(certificates: nil, name: nil)
      @certificates = certificates
      @name = name
    end

    # # Retrieve PixDomains
    #
    # Receive a generator of PixDomain objects registered at the Central Bank.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixDomain objects with updated attributes
    def self.query(user: nil)
      StarkInfra::Utils::Rest.get_stream(user: user, **resource)
    end

    def self._parse_certificates(certificates)
      certificate_maker = StarkInfra::Certificate.resource[:resource_maker]
      parsed_certificates = []
      certificates.each do |certificate|
        parsed_certificates << StarkInfra::Utils::API.from_api_json(certificate_maker, certificate)
      end
      parsed_certificates
    end

    def self.resource
      {
        resource_name: 'PixDomain',
        resource_maker: proc { |json|
          PixDomain.new(
            name: json['name'],
            certificates: _parse_certificates(json['certificates'])
          )
        }
      }
    end
  end
end
