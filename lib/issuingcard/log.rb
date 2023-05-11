# frozen_string_literal: true

require_relative('issuingcard')
require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  class IssuingCard
    # # IssuingCard::Log object
    #
    # Every time an IssuingCard entity is updated, a corresponding IssuingCard::Log is generated for the entity. This log
    # is never generated by the user, but it can be retrieved to check additional information on the IssuingCard.
    #
    # ## Attributes (return-only):
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - card [IssuingCard]: IssuingCard entity to which the log refers to.
    # - type [string]: type of the IssuingCard event which triggered the log creation. ex: 'processing' or 'success'
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Log < StarkInfra::Utils::Resource
      attr_reader :id, :created, :type, :card
      def initialize(id:, created:, type:, card:)
        super(id)
        @type = type
        @card = card
        @created = StarkInfra::Utils::Checks.check_datetime(created)
      end

      # # Retrieve a specific IssuingCard::Log
      #
      # Receive a single IssuingCard::Log object previously created by the Stark Infra API by passing its id
      #
      # ## Parameters (required):
      # - id [string]: object unique id. ex: '5656565656565656'
      #
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - IssuingCard::Log object with updated attributes
      def self.get(id, user: nil)
        StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
      end

      # # Retrieve IssuingCard::Logs
      #
      # Receive a generator of IssuingCard::Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ['blocked', 'canceled', 'created', 'expired', 'unblocked', 'updated']
      # - card_ids [list of strings, default nil]: list of IssuingCard ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - generator of IssuingCard::Log objects with updated attributes
      def self.query(limit: nil, after: nil, before: nil, types: nil, card_ids: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_stream(
          limit: limit,
          after: after,
          before: before,
          types: types,
          card_ids: card_ids,
          user: user,
          **resource
        )
      end

      # # Retrieve paged IssuingCard::Logs
      #
      # Receive a list of up to 100 IssuingCard::Log objects previously created in the Stark Infra API and the cursor to the next page.
      # Use this function instead of query if you want to manually page your logs.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ['blocked', 'canceled', 'created', 'expired', 'unblocked', 'updated']
      # - card_ids [list of strings, default nil]: list of IssuingCard ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - list of IssuingCard::Log objects with updated attributes
      # - Cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, limit: nil, after: nil, before: nil, types: nil, card_ids: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_page(
          cursor: cursor,
          limit: limit,
          after: after,
          before: before,
          types: types,
          card_ids: card_ids,
          user: user,
          **resource
        )
      end

      def self.resource
        request_maker = StarkInfra::IssuingCard.resource[:resource_maker]
        {
          resource_name: 'IssuingCardLog',
          resource_maker: proc { |json|
            Log.new(
              id: json['id'],
              created: json['created'],
              type: json['type'],
              card: StarkInfra::Utils::API.from_api_json(request_maker, json['card'])
            )
          }
        }
      end
    end
  end
end
