# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # IssuingStock object
  #
  # The IssuingStock object represents the current stock of a certain IssuingDesign linked to an Embosser available to your workspace.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingStock is created. ex: "5656565656565656"
  # - balance [integer]: [EXPANDABLE] current stock balance. ex: 1000
  # - design_id [string]: IssuingDesign unique id. ex: "5656565656565656"
  # - embosser_id [string]: Embosser unique id. ex: "5656565656565656"
  # - updated [DateTime]: latest update datetime for the IssuingStock. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingStock. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingStock < StarkInfra::Utils::Resource
    attr_reader :id, :balance, :design_id, :embosser_id, :updated, :created
    def initialize(
      id: nil, balance: nil, design_id: nil, embosser_id: nil, updated: nil, created: nil 
    )
      super(id)
      @balance = balance
      @design_id = design_id
      @embosser_id = embosser_id
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
      @created = StarkInfra::Utils::Checks.check_datetime(created)
    end

    # # Retrieve a specific IssuingStock
    #
    # Receive a single IssuingStock object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: fields to expand information. ex: ['balance']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingStock object with updated attributes
    def self.get(id, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, expand: expand, user: user, **resource)
    end

    # # Retrieve IssuingStocks
    #
    # Receive a generator of IssuingStocks objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - design_ids [list of strings, default nil]: IssuingDesign unique ids. ex: ["5656565656565656", "4545454545454545"]
    # - embosser_ids [list of strings, default nil]: Embosser unique ids. ex: ["5656565656565656", "4545454545454545"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - expand [list of strings, default []]: fields to expand information. ex: ["balance"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingStocks objects with updated attributes
    def self.query(
      limit: nil, after: nil, before: nil, design_ids: nil, embosser_ids: nil, ids: nil, expand: nil, user: nil
    )
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        design_ids: design_ids,
        embosser_ids: embosser_ids,
        ids: ids,
        expand: expand,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingStocks
    #
    # Receive a list of up to 100 IssuingStock objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - design_ids [list of strings, default nil]: IssuingDesign unique ids. ex: ["5656565656565656", "4545454545454545"]
    # - embosser_ids [list of strings, default nil]: Embosser unique ids. ex: ["5656565656565656", "4545454545454545"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - expand [list of strings, default []]: fields to expand information. ex: ["balance"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingStocks objects with updated attributes
    # - cursor to retrieve the next page of IssuingStocks objects
    def self.page(
      cursor: nil, limit: nil, after: nil, before: nil, design_ids: nil, embosser_ids: nil, 
      ids: nil, expand: nil, user: nil
    )
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        design_ids: design_ids,
        embosser_ids: embosser_ids,
        ids: ids,
        expand: expand,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingStock',
        resource_maker: proc { |json|
          IssuingStock.new(
            id: json['id'],
            balance: json['balance'],
            design_id: json['design_id'],
            embosser_id: json['embosser_id'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
