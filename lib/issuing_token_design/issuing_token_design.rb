# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingTokenDesign object
  #
  # The IssuingTokenDesign object displays the information of the token designs created in your Workspace.
  # This resource represents the existent designs for the cards which will be tokenized.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingTokenDesign is created. ex: '5656565656565656'
  # - name [string]: Design name. ex: 'Stark Bank - White Metal'
  # - created [DateTime]: creation datetime for the IssuingTokenDesign. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the IssuingTokenDesign. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingTokenDesign < StarkCore::Utils::Resource
    attr_reader :id, :name, :created, :updated
    def initialize(
      id: nil, name: nil, created: nil, updated: nil
    )
      super(id)
      @name = name
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Retrieve a specific IssuingTokenDesign
    #
    # Receive a single IssuingTokenDesign object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingTokenDesign object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingTokenDesigns
    #
    # Receive a generator of IssuingTokenDesign objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingTokenDesign objects with updated attributes
    def self.query(limit: nil, ids: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingTokenDesigns
    #
    # Receive a list of up to 100 IssuingTokenDesign objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingTokenDesign objects with updated attributes
    # - cursor to retrieve the next page of IssuingTokenDesign objects
    def self.page(cursor: nil, limit: nil, ids: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Retrieve a specific IssuingTokenDesign pdf file
    #
    # Receive a single IssuingTokenDesign pdf file generated in the Stark Infra API by its id.
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingTokenDesign pdf file
    def self.pdf(id, user: nil)
      StarkInfra::Utils::Rest.get_content(id: id, user: user, sub_resource_name: 'pdf', **resource)
    end

    def self.resource
      {
        resource_name: 'IssuingTokenDesign',
        resource_maker: proc { |json|
          IssuingTokenDesign.new(
            id: json['id'],
            name: json['name'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
