# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingProduct object
  #
  # The IssuingProduct object displays information of registered card products to your Workspace.
  # They represent a group of cards that begin with the same numbers (id) and offer the same product to end customers.
  #
  # ## Attributes (return-only):
  # - id [string]: unique card product number (BIN) registered within the card network. ex: '53810200'
  # - network [string]: card network flag. ex: 'mastercard'
  # - funding_type [string]: type of funding used for payment. ex: 'credit', 'debit'
  # - holder_type [string]: holder type. ex: 'business', 'individual'
  # - code [string]: internal code from card flag informing the product. ex: 'MRW', 'MCO', 'MWB', 'MCS'
  # - created [DateTime]: creation datetime for the IssuingProduct. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingProduct < StarkCore::Utils::Resource
    attr_reader :id, :network, :funding_type, :holder_type, :code, :created
    def initialize(id: nil, network: nil, funding_type: nil, holder_type: nil, code: nil, created: nil)
      super(id)
      @network = network
      @funding_type = funding_type
      @holder_type = holder_type
      @code = code
      @created = StarkCore::Utils::Checks.check_datetime(created)
    end

    # # Retrieve IssuingProducts
    #
    # Receive a generator of IssuingProduct objects previously registered in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingProduct objects with updated attributes
    def self.query(limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingProducts
    #
    # Receive a list of up to 100 IssuingProduct objects previously registered to your workspace and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingProduct objects with updated attributes
    # - cursor to retrieve the next page of IssuingProduct objects
    def self.page(cursor: nil, limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingProduct',
        resource_maker: proc { |json|
          IssuingProduct.new(
            id: json['id'],
            network: json['network'],
            funding_type: json['funding_type'],
            holder_type: json['holder_type'],
            code: json['code'],
            created: json['created']
          )
        }
      }
    end
  end
end
