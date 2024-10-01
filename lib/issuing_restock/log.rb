# frozen_string_literal: true

require('starkcore')
require_relative('issuing_restock')
require_relative('../utils/rest')

module StarkInfra
  class IssuingRestock
    # # IssuingRestock::Log object
    #
    # Every time an IssuingRestock entity is updated, a corresponding IssuingRestock::Log is generated for the entity. This log
    # is never generated by the user, but it can be retrieved to check additional information on the IssuingRestock.
    #
    # ## Attributes (return-only):
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - restock [IssuingRestock]: IssuingRestock entity to which the log refers to.
    # - type [string]: type of the IssuingRestock event which triggered the log creation. ex: "created", "processing", "confirmed"
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Log < StarkCore::Utils::Resource
      attr_reader :id, :restock, :type, :created 
      def initialize(id: nil, restock: nil, type: nil, created: nil)
        super(id)
        @restock = restock
        @type = type
        @created = StarkCore::Utils::Checks.check_datetime(created)
      end

      # # Retrieve a specific IssuingRestock::Log
      #
      # Receive a single IssuingRestock::Log object previously created by the Stark Infra API by passing its id
      #
      # ## Parameters (required):
      # - id [string]: object unique id. ex: '5656565656565656'
      #
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - IssuingRestock::Log object with updated attributes
      def self.get(id, user: nil)
        StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
      end

      # # Retrieve IssuingRestock::Logs
      #
      # Receive a generator of IssuingRestock::Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ["created", "processing", "confirmed"]
      # - restock_ids [list of strings, default nil]: list of IssuingRestock ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - generator of IssuingRestock::Log objects with updated attributes
      def self.query(
        limit: nil, after: nil, before: nil, types: nil, restock_ids: nil, ids: nil, user: nil
      )
        after = StarkCore::Utils::Checks.check_date(after)
        before = StarkCore::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_stream(
          limit: limit,
          after: after,
          before: before,
          types: types,
          restock_ids: restock_ids,
          ids: ids,
          user: user,
          **resource
        )
      end

      # # Retrieve paged IssuingRestock::Logs
      #
      # Receive a list of up to 100 IssuingRestock::Log objects previously created in the Stark Infra API and the cursor to the next page.
      # Use this function instead of query if you want to manually page your logs.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ["created", "processing", "confirmed"]
      # - restock_ids [list of strings, default nil]: list of IssuingRestock ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - list of IssuingRestock::Log objects with updated attributes
      # - Cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, limit: nil, after: nil, before: nil, types: nil, restock_ids: nil, ids: nil, user: nil)
        after = StarkCore::Utils::Checks.check_date(after)
        before = StarkCore::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_page(
          cursor: cursor,
          limit: limit,
          after: after,
          before: before,
          types: types,
          restock_ids: restock_ids,
          ids: ids,
          user: user,
          **resource
        )
      end

      def self.resource
        request_maker = StarkInfra::IssuingRestock.resource[:resource_maker]
        {
          resource_name: 'IssuingRestockLog',
          resource_maker: proc { |json|
            Log.new(
              id: json['id'],
              restock: StarkCore::Utils::API.from_api_json(request_maker, json['restock']),
              type: json['type'],
              created: json['created']
            )
          }
        }
      end
    end
  end
end