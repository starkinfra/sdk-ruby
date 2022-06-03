# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')

module StarkInfra
  # # IssuingBin object
  #
  # The IssuingBin object displays information of BINs registered to your Workspace.
  # They represent a group of cards that begin with the same numbers (BIN) and offer the same product to end customers.
  #
  # ## Attributes (return-only):
  # - id [string]: unique BIN number registered within the card network. ex: '53810200'
  # - network [string]: card network flag. ex: 'mastercard'
  # - settlement [string]: settlement type. ex: 'credit'
  # - category [string]: purchase category. ex: 'prepaid'
  # - client [string]: client type. ex: 'business'
  # - created [DateTime]: creation datetime for the IssuingBin. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the IssuingBin. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingBin < StarkInfra::Utils::Resource
    attr_reader :id, :network, :settlement, :category, :client, :updated, :created
    def initialize(id: nil, network: nil, settlement: nil, category: nil, client: nil, updated: nil, created: nil)
      super(id)
      @network = network
      @settlement = settlement
      @category = category
      @client = client
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
      @created = StarkInfra::Utils::Checks.check_datetime(created)
    end

    # # Retrieve the IssuingBin object
    #
    # Receive a generator of IssuingBin objects previously registered in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingBin objects with updated attributes
    def self.query(limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingBins
    #
    # Receive a list of up to 100 IssuingBin objects previously registered in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingBin objects with updated attributes
    # - cursor to retrieve the next page of IssuingBin objects
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
        resource_name: 'IssuingBin',
        resource_maker: proc { |json|
          IssuingBin.new(
            id: json['id'],
            network: json['network'],
            settlement: json['settlement'],
            category: json['category'],
            client: json['client'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
