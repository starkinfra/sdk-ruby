# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingTokenRequest object
  #
  # The IssuingTokenRequest object displays the necessary information to proceed with the card tokenization.
  #
  # ## Parameters (required):
  # - card_id [string]: card id to be tokenized. ex: '5734340247945216'
  # - wallet_id [string]: desired wallet to be integrated. ex: 'google'
  # - method_code [string]: method code. ex: 'app' or 'manual'
  #
  # ## Attributes (return-only):
  # - content [string]: token request content. ex: 'eyJwdWJsaWNLZXlGaW5nZXJwcmludCI6ICJlNTNiZThjZTRhYWQxNWU2OWNmMjExOTA5Mjk4YzJkOTE0O...'
  # - signature [string]: token request signature. ex: 'eyJwdWJsaWNLZXlGaW5nZXJwcmludCI6ICJlNTNiZThjZTRhYWQxNWU2OWNmMjExOTA5Mjk4YzJkOTE0O...'
  # - metadata [hash]: hash object used to store additional information about the IssuingTokenRequest object.
  class IssuingTokenRequest < StarkCore::Utils::SubResource
    attr_reader :card_id, :wallet_id, :method_code, :content, :signature, :metadata
    def initialize(card_id:, wallet_id:, method_code:, content: nil, signature: nil, metadata: nil)
      @card_id = card_id
      @wallet_id = wallet_id
      @method_code = method_code
      @content = content
      @signature = signature
      @metadata = metadata
    end

    # # Create an IssuingTokenRequest object
    #
    # Send an IssuingTokenRequest object to Stark Infra API to create the payload to proceed with the card tokenization
    #
    # ## Parameters (required):
    # - request [IssuingTokenRequest object]: IssuingTokenRequest object to the API to generate the payload
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingTokenRequest object with updated attributes
    def self.create(request, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: request, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'IssuingTokenRequest',
        resource_maker: proc { |json|
          IssuingTokenRequest.new(
            card_id: json['card_id'],
            wallet_id: json['wallet_id'],
            method_code: json['method_code'],
            content: json['content'],
            signature: json['signature'],
            metadata: json['metadata']
          )
        }
      }
    end
  end
end
