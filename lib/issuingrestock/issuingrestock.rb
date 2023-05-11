# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # IssuingRestock object
  #
  # The IssuingRestock object displays the information of the restock orders created in your Workspace. 
  # This resource place a restock order for a specific IssuingStock object.
  #
  # ## Parameters (required):
  # - count [integer]: number of restocks to be restocked. ex: 100
  # - stock_id [string]: IssuingStock unique id ex: "5136459887542272"
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ["card", "corporate"]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingRestock is created. ex: '5656565656565656'
  # - status [string]: current IssuingRestock status. ex: "created", "processing", "confirmed"
  # - updated [DateTime]: latest update datetime for the IssuingRestock. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingRestock. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingRestock < StarkInfra::Utils::Resource
    attr_reader :count, :stock_id, :tags, :id, :status, :updated, :created 
    def initialize(
      count:, stock_id:, tags: nil, id: nil, status: nil, updated: nil, created: nil 
    )
      super(id)
      @count = count
      @stock_id = stock_id
      @tags = tags
      @status = status
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    # # Create IssuingRestocks
    #
    # Send a list of IssuingRestock objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - restocks [list of IssuingRestock objects]: list of IssuingRestock objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingRestock objects with updated attributes
    def self.create(restocks:, user: nil)
      StarkInfra::Utils::Rest.post(entities: restocks, user: user, **resource)
    end

    # # Retrieve a specific IssuingRestock
    #
    # Receive a single IssuingRestock object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingRestock object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingRestocks
    #
    # Receive a generator of IssuingRestock objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "confirmed"]
    # - stock_ids [list of string, default nil]: list of stock_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ["card", "corporate"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingRestocks objects with updated attributes
    def self.query(
      limit: nil, after: nil, before: nil, status: nil, stock_ids: nil, ids: nil, 
      tags: nil, user: nil
    )
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        stock_ids: stock_ids,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingRestocks
    #
    # Receive a list of up to 100 IssuingRestock objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "confirmed"]
    # - stock_ids [list of string, default nil]: list of stock_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ["card", "corporate"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingRestocks objects with updated attributes
    # - cursor to retrieve the next page of IssuingRestocks objects
    def self.page(
      cursor: nil, limit: nil, after: nil, before: nil, status: nil, stock_ids: nil, 
      ids: nil, tags: nil, user: nil
      )
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        stock_ids: stock_ids,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingRestock',
        resource_maker: proc { |json|
          IssuingRestock.new(
            count: json['count'],
            stock_id: json['stock_id'],
            tags: json['tags'],
            id: json['id'],
            status: json['status'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
