# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('issuingpurchase')
require_relative('../utils/resource')

module StarkInfra
  class IssuingPurchase
    # # IssuingPurchase::Log object
    #
    # Every time an IssuingPurchase entity is updated, a corresponding IssuingInvoice::Log is generated for the entity.
    # This Log is never generated by the user, but it can be retrieved to check additional information on the IssuingPurchase.
    #
    # ## Attributes (return-only):
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - purchase [IssuingPurchase]: IssuingPurchase entity to which the log refers to.
    # - issuing_transaction_id [string]: transaction ID related to the IssuingCard.
    # - errors [list of strings]: list of errors linked to this IssuingPurchase event
    # - type [string]: type of the IssuingPurchase event which triggered the log creation. ex: 'approved', 'canceled', 'confirmed', 'denied', 'reversed', 'voided'.
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Log < StarkInfra::Utils::Resource
      attr_reader :id, :purchase, :issuing_transaction_id, :errors, :type, :created
      def initialize(id: nil, purchase: nil, issuing_transaction_id: nil, errors: nil, type: nil, created: nil)
        super(id)
        @purchase = purchase
        @issuing_transaction_id = issuing_transaction_id
        @errors = errors
        @type = type
        @created = StarkInfra::Utils::Checks.check_datetime(created)
      end

      # # Retrieve a specific IssuingPurchase::Log
      #
      # Receive a single IssuingPurchase::Log object previously created by the Stark Infra API by passing its id
      #
      # ## Parameters (required):
      # - id [string]: object unique id. ex: '5656565656565656'
      #
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - IssuingPurchase::Log object with updated attributes
      def self.get(id, user: nil)
        StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
      end

      # # Retrieve IssuingPurchase::Logs
      #
      # Receive a generator of IssuingPurchase::Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ['approved', 'canceled', 'confirmed', 'denied', 'reversed', 'voided']
      # - purchase_ids [list of strings, default nil]: list of Purchase ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - ids [list of strings, default nil]: list of IssuingPurchase ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - generator of IssuingPurchase::Log objects with updated attributes
      def self.query(ids: nil, limit: nil, after: nil, before: nil, types: nil, purchase_ids: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_stream(
          ids: ids,
          limit: limit,
          after: after,
          before: before,
          types: types,
          purchase_ids: purchase_ids,
          user: user,
          **resource
        )
      end

      # # Retrieve paged IssuingPurchase::Logs
      #
      # Receive a list of up to 100 Log objects previously created in the Stark Infra API and the cursor to the next page.
      # Use this function instead of query if you want to manually page your purchases.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ['approved', 'canceled', 'confirmed', 'denied', 'reversed', 'voided']
      # - purchase_ids [list of strings, default nil]: list of Purchase ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - ids [list of strings, default nil]: list of IssuingPurchase ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - list of IssuingPurchase::Log objects with updated attributes
      # - cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, ids: nil, limit: nil, after: nil, before: nil, types: nil, purchase_ids: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_page(
          cursor: cursor,
          ids: ids,
          limit: limit,
          after: after,
          before: before,
          types: types,
          purchase_ids: purchase_ids,
          user: user,
          **resource
        )
      end

      def self.resource
        request_maker = StarkInfra::IssuingPurchase.resource[:resource_maker]
        {
          resource_name: 'IssuingPurchaseLog',
          resource_maker: proc { |json|
            Log.new(
              id: json['id'],
              purchase: StarkInfra::Utils::API.from_api_json(request_maker, json['purchase']),
              issuing_transaction_id: json['issuing_transaction_id'],
              errors: json['errors'],
              type: json['type'],
              created: json['created']
            )
          }
        }
      end
    end
  end
end
