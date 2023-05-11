# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # IssuingEmbossingKit object
  #
  # The IssuingEmbossingKit object displays information on the embossing kits available to your Workspace.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingEmbossingKit is created. ex: "5656565656565656"
  # - name [string]: card or package design name. ex: "stark-plastic-dark-001"
  # - designs [list of IssuingDesign objects]: list of IssuingDesign objects. ex: [IssuingDesign(), IssuingDesign()]
  # - updated [DateTime]: latest update datetime for the IssuingEmbossingKit. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingEmbossingKit. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingEmbossingKit < StarkInfra::Utils::Resource
    attr_reader :id, :name, :designs, :updated, :created
    def initialize(
      id: nil, name: nil, designs: nil, updated: nil, created: nil
    )
      super(id)
      @name = name
      @designs = IssuingDesign::parse_designs(designs)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
      @created = StarkInfra::Utils::Checks.check_datetime(created)
    end

    # # Retrieve a specific IssuingEmbossingKit
    #
    # Receive a single IssuingEmbossingKit object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingEmbossingKit object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingEmbossingKits
    #
    # Receive a generator of IssuingEmbossingKits objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "success", "failed"]
    # - design_ids [list of string, default nil]: list of design_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingEmbossingKits objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, design_ids: nil, ids: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        design_ids: design_ids,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingEmbossingKits
    #
    # Receive a list of up to 100 IssuingEmbossingKit objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "success", "failed"]
    # - design_ids [list of string, default nil]: list of design_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingEmbossingKit objects with updated attributes
    # - cursor to retrieve the next page of IssuingEmbossingKit objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, design_ids: nil, ids: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        design_ids: design_ids,
        ids: ids,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingEmbossingKit',
        resource_maker: proc { |json|
          IssuingEmbossingKit.new(
            id: json['id'],
            name: json['name'],
            designs: json['designs'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
