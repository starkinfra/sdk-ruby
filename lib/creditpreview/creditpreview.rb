# frozen_string_literal: true

require_relative('../utils/api')
require_relative('../utils/rest')
require_relative('../utils/sub_resource')

module StarkInfra
  # # CreditPreview object
  #
  # A CreditPreview is used to get information from a credit before taking it.
  # This resource can be used to preview credit notes.
  #
  # When you initialize a CreditPreview, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - credit [CreditNotePreview object or hash]: Information preview of the informed credit.
  #
  # ## Parameters (conditionally required):
  # - type [string]: Credit type, inferred from the payment parameter if it is not a dictionary. ex: 'credit-note'
  class CreditPreview < StarkInfra::Utils::SubResource
    attr_reader :credit, :type
    def initialize(credit:, type: nil)
      credit_info = CreditPreview.parse_credit(credit, type)
      @credit = credit_info['credit']
      @type = credit_info['type']

    end

    # # Create CreditPreviews
    #
    # Send a list of CreditPreview objects for processing in the Stark Infra API
    #
    # ## Parameters (required):
    # - previews [list of CreditPreview objects]: list of CreditPreview objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of CreditPreview objects with updated attributes
    def self.create(previews, user: nil)
      StarkInfra::Utils::Rest.post(entities: previews, user: user, **resource)
    end

    def self.parse_credit(credit, type)
      resource_maker = { 'credit-note' => StarkInfra::CreditNotePreview.resource[:resource_maker] }
      if credit.is_a?(Hash)
        begin
          parsed_credit = StarkInfra::Utils::API.from_api_json(resource_maker[type], credit)
          return { 'credit' => parsed_credit, 'type' => type }

        rescue StandardError
          return { 'credit' => credit, 'type' => type }

        end
      end

      return { 'credit' => credit, 'type' => type } if type

      if credit.class == StarkInfra::CreditNotePreview
        return { 'credit' => credit, 'type' => 'credit-note' }

      end

      raise 'credit must be either ' + 'a dictionary, ' \
              'a CreditNote.CreditNotePreview, but not a ' + credit.class.to_s
    end

    def self.resource
      {
        resource_name: 'CreditPreview',
        resource_maker: proc { |json|
          CreditPreview.new(
            credit: json['credit'],
            type: json['type']
          )
        }
      }
    end
  end
end
