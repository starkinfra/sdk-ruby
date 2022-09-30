# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('issuinginvoice')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  class IssuingInvoice
    # # IssuingInvoice::Log object
    #
    # Every time an IssuingInvoice entity is updated, a corresponding IssuingInvoice::Log is generated for the entity.
    # This log is never generated by the user, but it can be retrieved to check additional information on the
    # IssuingInvoice.
    #
    # ## Attributes:
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - invoice [IssuingInvoice]: IssuingInvoice entity to which the log refers to.
    # - type [string]: type of the IssuingInvoice event which triggered the log creation. ex: 'created', 'credited', 'expired', 'overdue', 'paid'.
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Log < StarkInfra::Utils::Resource
      attr_reader :id, :created, :type, :invoice
      def initialize(id:, created:, type:, invoice:)
        super(id)
        @type = type
        @invoice = invoice
        @created = StarkInfra::Utils::Checks.check_datetime(created)
      end

      # # Retrieve a specific Log
      #
      # Receive a single Log object previously created by the Stark Infra API by its id
      #
      # ## Parameters (required):
      # - id [string]: object unique id. ex: '5656565656565656'
      #
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - Log object with updated attributes
      def self.get(id, user: nil)
        StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
      end

      # # Retrieve Logs
      #
      # Receive a generator of Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - ids [list of strings, default nil]: list of IssuingInvoice ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ['created', 'credited', 'expired', 'overdue', 'paid']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - generator of Log objects with updated attributes
      def self.query(limit: nil, after: nil, before: nil, types: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_stream(
          limit: limit,
          after: after,
          before: before,
          types: types,
          user: user,
          **resource
        )
      end

      # # Retrieve paged Logs
      #
      # Receive a list of up to 100 issuinginvoice.Log objects previously created in the Stark Infra API and the cursor
      # to the next page. Use this function instead of query if you want to manually page your invoices.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - ids [list of strings, default nil]: list of IssuingInvoice ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ['created', 'credited', 'expired', 'overdue', 'paid']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - list of Log objects with updated attributes
      # - cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, limit: nil, after: nil, before: nil, types: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_page(
          cursor: cursor,
          limit: limit,
          after: after,
          before: before,
          types: types,
          user: user,
          **resource
        )
      end

      def self.resource
        request_maker = StarkInfra::IssuingInvoice.resource[:resource_maker]
        {
          resource_name: 'IssuingInvoiceLog',
          resource_maker: proc { |json|
            Log.new(
              id: json['id'],
              created: json['created'],
              type: json['type'],
              invoice: StarkInfra::Utils::API.from_api_json(request_maker, json['invoice'])
            )
          }
        }
      end
    end
  end
end
