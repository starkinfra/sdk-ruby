# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/parse')
require('starkcore')

module StarkInfra
  # # CreditSigner object
  #
  # CreditNote signer's information.
  #
  # ## Parameters (required):
  # - name [string]: signer's name. ex: 'Tony Stark'
  # - contact [string]: signer's contact information. ex: 'tony@starkindustries.com'
  # - method [string]: delivery method for the contract. ex: 'link'
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the CreditSigner is created. ex: '5656565656565656'
  class CreditSigner < StarkCore::Utils::Resource
    attr_reader :name, :contact, :method, :id
    def initialize(name:, contact:, method:, id: nil)
      super(id)
      @name = name
      @contact = contact
      @method = method
    end

    def self.parse_signers(signers)
      resource_maker = StarkInfra::CreditSigner.resource[:resource_maker]
      return signers if signers.nil?

      parsed_signers = []
      signers.each do |signer|
        unless signer.is_a? CreditSigner
          signer = StarkCore::Utils::API.from_api_json(resource_maker, signer)
        end
        parsed_signers << signer
      end
      parsed_signers
    end

    def self.resource
      {
        resource_name: 'CreditSigner',
        resource_maker: proc { |json|
          CreditSigner.new(
            id: json['id'],
            name: json['name'],
            contact: json['contact'],
            method: json['method']
          )
        }
      }
    end
  end
end
